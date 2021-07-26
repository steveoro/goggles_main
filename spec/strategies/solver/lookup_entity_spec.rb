# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::LookupEntity, type: :strategy do
  %w[
    DisqualificationCodeType
    EditionType
    EventType
    GenderType
    PoolType
    SeasonType
    TimingType
  ].each do |target_name|
    context "target: #{target_name}," do
      let(:entity_name) { target_name.tableize.singularize }
      let(:entity_class) { GogglesDb.module_eval(target_name) }

      context 'before #solve!,' do
        it_behaves_like('Solver strategy, NO bindings, finder ONLY, before #solve!', target_name, Solver::LookupEntity)
      end
      #-- -------------------------------------------------------------------------
      #++

      #
      # INVALID data: empty request
      #
      context 'with EMPTY #req data,' do
        let(:fixture_req) { {} }
        it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', target_name)
      end

      #
      # INVALID data: BAD ID, @ root
      #
      context 'with INVALID #req data (non-existing id @ root lv.),' do
        let(:fixture_req) { { "#{entity_name}_id" => -1 } }
        it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', target_name)
      end

      #
      # INVALID data: BAD ID, @ sub-entity
      #
      context 'with INVALID #req data (non-existing id @ sub-entity lv.),' do
        let(:fixture_req) { { entity_name => { 'id' => -1 } } }
        it_behaves_like('Solver strategy, NO bindings, UNSOLVABLE req, after #solve!', target_name)
      end
      #-- -------------------------------------------------------------------------
      #++

      #
      # VALID data: EXISTING ID, @ root
      #
      context 'with valid & solved #req data (valid id @ root lv.),' do
        let(:fixture_req) { { "#{entity_name}_id" => entity_class.all.sample.id } }
        let(:expected_id) { fixture_req["#{entity_name}_id"] }
        it_behaves_like('Solver strategy, NO bindings, solvable req, after #solve!', target_name, GogglesDb.module_eval(target_name))
      end

      #
      # VALID data: EXISTING ID, @ sub-entity
      #
      context 'with valid & solved #req data (valid id @ sub-entity lv.),' do
        let(:fixture_req) { { entity_name => { 'id' => entity_class.all.sample.id } } }
        let(:expected_id) { fixture_req[entity_name]['id'] }
        it_behaves_like('Solver strategy, NO bindings, solvable req, after #solve!', target_name, GogglesDb.module_eval(target_name))
      end
      #-- -------------------------------------------------------------------------
      #++

      #
      # VALID data: EXISTING code, @ root
      #
      context 'with valid & solved #req data (valid code @ root lv.),' do
        let(:fixture_req) { { "#{entity_name}_code" => entity_class.all.sample.code } }
        let(:expected_id) { false }
        it_behaves_like('Solver strategy, NO bindings, solvable req, after #solve!', target_name, GogglesDb.module_eval(target_name))
      end

      #
      # VALID data: EXISTING code, @ sub-entity
      #
      context 'with valid & solved #req data (valid code @ sub-entity lv.),' do
        let(:fixture_req) { { entity_name => { 'code' => entity_class.all.sample.code } } }
        let(:expected_id) { false }
        it_behaves_like('Solver strategy, NO bindings, solvable req, after #solve!', target_name, GogglesDb.module_eval(target_name))
      end
      #-- -------------------------------------------------------------------------
      #++
    end
  end
end
