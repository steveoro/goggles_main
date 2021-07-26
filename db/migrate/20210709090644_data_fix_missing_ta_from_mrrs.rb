# frozen_string_literal: true

require 'goggles_db/version'

class DataFixMissingTaFromMrrs < ActiveRecord::Migration[6.0]
  def self.up
    puts "\r\n--> MeetingRelayResult: fixing missing TeamAffiliations..."
    missing_ta_condition = 'team_affiliation_id is null'
    count = GogglesDb::MeetingRelayResult.where(missing_ta_condition).count
    puts "Count at start: #{count}"

    # Search for a valid TA for the MRR missing it:
    GogglesDb::MeetingRelayResult.where(missing_ta_condition).each do |mrr|
      ta = mrr.team.team_affiliations.where(season_id: mrr.season.id).first
      mrr.team_affiliation_id = ta.id
      mrr.save!
      $stdout.write("\033[1;33;32m.\033[0m")
    end

    count = GogglesDb::MeetingRelayResult.where(missing_ta_condition).count
    puts "\r\nFinal count: #{count}"
  end

  def self.down
    # (no-op)
  end
end
