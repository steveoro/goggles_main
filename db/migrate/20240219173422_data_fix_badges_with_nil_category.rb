# frozen_string_literal: true

# rubocop:disable Rails/Output
class DataFixBadgesWithNilCategory < ActiveRecord::Migration[6.0]
  def self.up
    puts("\r\n--> Fixing badges with nil category_type...")
    domain = GogglesDb::Badge.includes(:season, :swimmer)
                             .joins(:season, :swimmer)
                             .where(category_type_id: nil)
    puts("    Found #{domain.count} rows.")
    domain.find_each do |badge|
      swimmer = badge.swimmer
      season = badge.season
      found_age = swimmer.age(season.begin_date + 2.months)
      possible_category = GogglesDb::CategoryType.where(season_id: badge.season_id, relay: false)
                                                 .where('(age_begin <= ?) AND (age_end >= ?)', found_age, found_age)
                                                 .first
      if possible_category
        badge.category_type_id = possible_category.id
        badge.save!
      else
        puts('    ERROR: category_type NOT found.')
      end
    end
    puts("    Done! (#{GogglesDb::Badge.where(category_type_id: nil).count} rows remaining.)")
  end

  def self.down
    # (no-op)
  end
end
# rubocop:enable Rails/Output
