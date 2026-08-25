# frozen_string_literal: true

class CreateGogglesDbBaseYearFunction < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL.squish
      CREATE OR REPLACE FUNCTION goggles_db_base_year()
      RETURNS INT
      NOT DETERMINISTIC
      READS SQL DATA
      RETURN IFNULL(
        CAST(@base_year AS SIGNED),
        (SELECT
           CASE
             WHEN MONTH(s.begin_date) >= 9 THEN YEAR(s.begin_date)
             WHEN MONTH(s.begin_date) <= 5 THEN YEAR(s.begin_date) - 1
             ELSE YEAR(s.end_date)
           END AS championship_year
         FROM seasons s
         WHERE s.end_date >= CURRENT_DATE()
         ORDER BY s.begin_date DESC, s.id DESC
         LIMIT 1)
      );
    SQL
  end

  def down
    execute 'DROP FUNCTION IF EXISTS goggles_db_base_year;'
  end
end
