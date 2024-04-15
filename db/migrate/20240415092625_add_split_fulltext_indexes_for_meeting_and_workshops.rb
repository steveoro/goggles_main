# frozen_string_literal: true

class AddSplitFulltextIndexesForMeetingAndWorkshops < ActiveRecord::Migration[6.1]
  def self.up
    execute('CREATE FULLTEXT INDEX meeting_code ON meetings(code);')
    execute('CREATE FULLTEXT INDEX meeting_desc ON meetings(description);')
    execute('CREATE FULLTEXT INDEX workshop_code ON user_workshops(code);')
    execute('CREATE FULLTEXT INDEX workshop_desc ON user_workshops(description);')
    execute('CREATE FULLTEXT INDEX team_only_name ON teams(name);')
    execute('CREATE FULLTEXT INDEX team_editable_name ON teams(editable_name);')
    execute('CREATE FULLTEXT INDEX team_name_variations ON teams(name_variations);')
  end

  def self.down
    execute('ALTER TABLE meetings DROP INDEX meeting_code;')
    execute('ALTER TABLE meetings DROP INDEX meeting_desc;')
    execute('ALTER TABLE user_workshops DROP INDEX workshop_code;')
    execute('ALTER TABLE user_workshops DROP INDEX workshop_desc;')
    execute('ALTER TABLE teams DROP INDEX team_only_name;')
    execute('ALTER TABLE teams DROP INDEX team_editable_name;')
    execute('ALTER TABLE teams DROP INDEX team_name_variations;')
  end
end
