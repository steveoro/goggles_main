# frozen_string_literal: true

require 'goggles_db/version'

class DataFixWrongCountryCodeCities < ActiveRecord::Migration[6.0]
  def self.up
    Rails.logger.debug "\r\n--> Cities: fixing wrong country code (IT) for cities in test dump..."
    wrong_cc_condition = "(country != 'Italy') AND (country_code = 'IT')"
    count = GogglesDb::City.where(wrong_cc_condition).count
    Rails.logger.debug { "Count at start: #{count}" }

    # Give priority to the ISO definition:
    GogglesDb::City.where(wrong_cc_condition).each do |city|
      city.country = city.iso_attributes['country']
      city.country_code = city.iso_attributes['country_code']
      city.save!
    end

    count = GogglesDb::City.where(wrong_cc_condition).count
    Rails.logger.debug { "Final count: #{count}" }
  end

  def self.down
    # (no-op)
  end
end
