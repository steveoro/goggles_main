# frozen_string_literal: true

class RenameFINCalendarsToCalendars < ActiveRecord::Migration[6.0]
  def self.up
    rename_table(:fin_calendars, :calendars)

    rename_column(:calendars, :calendar_date, :scheduled_date)
    rename_column(:calendars, :calendar_name, :meeting_name)
    rename_column(:calendars, :calendar_place, :meeting_place)
    rename_column(:calendars, :goggles_meeting_code, :meeting_code)

    rename_column(:calendars, :fin_manifest_code, :manifest_code)
    rename_column(:calendars, :fin_startlist_code, :startlist_code)
    rename_column(:calendars, :fin_results_code, :results_code)

    rename_column(:calendars, :calendar_year, :year)
    rename_column(:calendars, :calendar_month, :month)
    rename_column(:calendars, :do_not_update, :read_only)
  end

  def self.down
    rename_table(:calendars, :fin_calendars)

    rename_column(:fin_calendars, :scheduled_date, :calendar_date)
    rename_column(:fin_calendars, :meeting_name, :calendar_name)
    rename_column(:fin_calendars, :meeting_place, :calendar_place)
    rename_column(:fin_calendars, :meeting_code, :goggles_meeting_code)

    rename_column(:fin_calendars, :manifest_code, :fin_manifest_code)
    rename_column(:fin_calendars, :startlist_code, :fin_startlist_code)
    rename_column(:fin_calendars, :results_code, :fin_results_code)

    rename_column(:fin_calendars, :year, :calendar_year)
    rename_column(:fin_calendars, :month, :calendar_month)
    rename_column(:fin_calendars, :read_only, :do_not_update)
  end
end
