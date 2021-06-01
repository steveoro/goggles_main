# frozen_string_literal: true

class AddFulltextIndexToUserWorkshops < ActiveRecord::Migration[6.0]
  def self.up
    execute('CREATE FULLTEXT INDEX workshop_name ON user_workshops(description, code);')
  end

  def self.down
    execute('ALTER TABLE user_workshops DROP INDEX workshop_name;')
  end
end
