# frozen_string_literal: true

require 'ostruct'

# = ToolsController
#
# Miscellaneous calculators and more
#
class ToolsController < ApplicationController
  # Data entry for FIN score computation
  #
  # == Params
  #
  # TODO
  def fin_score
    @fin_params = OpenStruct.new(
      category_type: default_category,
      gender_type: default_gender,
      pool_type: GogglesDb::PoolType.mt_50,
      event_type: GogglesDb::EventType.all_individuals.first
    )
  end

  # (POST) Compute FIN score
  #
  # == Params
  #
  # TODO: MOVE THIS TO DEDICATED API ENDPOINT
  def compute_fin_score
    # TODO
  end

  private

  # Returns default CategoryType for FIN score computation
  def default_category
    current_user&.swimmer&.badges&.last&.category_type || GogglesDb::CategoryType.individuals.first
  end

  # Returns default GenderType for FIN score computation
  def default_gender
    current_user&.swimmer&.gender_type || GogglesDb::GenderType.female
  end
end
