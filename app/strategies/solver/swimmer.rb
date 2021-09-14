# frozen_string_literal: true

# = Solver module
#
# Wraps all micro-transaction solver strategies.
#
module Solver
  #
  # = Swimmer solver strategy object
  #
  #   - version:  7.3.07
  #   - author:   Steve A.
  #
  # Resolves the request for building a new GogglesDb::Swimmer.
  #
  class Swimmer < BaseStrategy
    # Returns the first entity row found that matches the finder criteria.
    # Returns +nil+ when not found.
    #
    # == Finder criteria:
    # 1. id: matched by equality
    # 2. bindings match: complete_name + year_of_birth + gender_type_id
    # 3. complete_name: full-text search index on #complete_name, FIFO order
    #
    def finder_strategy
      return nil if @bindings.empty?

      id = value_from_req(key: 'swimmer_id', nested: 'swimmer', sub_key: 'id')
      # Priority #1
      return GogglesDb::Swimmer.find_by(id: id) if id.to_i.positive?

      # Priority #2
      solve_bindings
      if all_bindings_solved?
        return GogglesDb::Swimmer.where(
          complete_name: @bindings[:complete_name],
          year_of_birth: @bindings[:year_of_birth],
          gender_type_id: @bindings[:gender_type_id]
        ).first
      end

      # Priority #3
      # Assumes: first match = best match
      GogglesDb::Swimmer.for_complete_name(@bindings[:complete_name]).first if @bindings[:complete_name]
    end
    #-- -----------------------------------------------------------------------
    #++

    # Returns a newly created target entity instance, serialized if and only if
    # all the bindings were solved and the resulting row was valid.
    #
    # == Returns:
    # - +nil+ until all required bindings are solved;
    # - a new target entity instance when done, saved successfully if valid,
    #   and yielding any validation erros as #error_messages.
    #
    # == Arguments:
    # - complete_name: Swimmer#complete_name used when creating a new instance
    # - year_of_birth: as above, Swimmer#year_of_birth
    # - last_name: as above, Swimmer#last_name
    # - first_name: as above, Swimmer#first_name
    #
    def creator_strategy
      return nil if @bindings.empty?

      solve_bindings
      return nil unless all_bindings_solved?

      new_instance = GogglesDb::Swimmer.new
      # * complete_name - by value_from_req['label']
      #                   => supplied || composable from first & last (if these 2 are supplied
      #                   => if all are missing, remains unsolvable)
      # - year_of_birth...: supplied || guessable by AgeGuesser(new_row, category_type_id) => year_guessed: true (TODO)
      # - last_name.......: supplied || guessable by #name_splitter(new_row)
      # - first_name......: supplied || guessable by #name_splitter(new_row)
      bindings.each { |key, solved| new_instance.send("#{key}=", solved) unless solved.nil? }
      # Make sure every new instance has also the split-name if missing:
      new_instance = name_splitter(new_instance) unless new_instance.complete_name.nil? ||
                                                        new_instance.last_name.present?
      new_instance.save # Don't throw validation errors
      new_instance
    end
    #-- -----------------------------------------------------------------------
    #++

    protected

    # Hash of required bindings/associations that have to be resolved, using format:
    #
    #     key_column_name.to_sym => solver_instance || value_from_req
    #
    # A direct attribute binding will be resolved to +nil+ if can't be found inside the
    # current data set after a call to #solve!.
    #
    def init_bindings
      @bindings = {
        # TODO: make custom strategies for having "optional" fields like first_name or year_of_birth
        #       deduced from other req values like 'category_type_id' from the overall request
        #       by calling the strategy with a filtered sub-request like we are now doing for GenderType
        # first_name: value_from_req(key: 'first_name', nested: 'swimmer', sub_key: 'first_name'),
        # last_name: value_from_req(key: 'last_name', nested: 'swimmer', sub_key: 'last_name'),

        complete_name: value_from_req(key: 'swimmer_complete_name', nested: 'swimmer', sub_key: 'complete_name'),
        year_of_birth: value_from_req(key: 'year_of_birth', nested: 'swimmer', sub_key: 'year_of_birth'),
        # Can use either nested or root gender_type, with precedence on nested:
        gender_type_id: Solver::Factory.for('GenderType', root_key?('gender_type') ? req : req['swimmer'])
      }
    end

    private

    # Crude name splitter.
    # Tries to split new_instance#complete_name in two, given:
    #
    # 1. complete_name = last_name + ' ' + first_name
    # 2. dual first names are more common than dual surnames
    #
    def name_splitter(new_instance)
      names = new_instance.complete_name.split
      new_instance.last_name = names.first
      new_instance.first_name = names.split[1..].join(' ')
      new_instance
    end
  end
end
