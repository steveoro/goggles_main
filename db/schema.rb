# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_04_15_111509) do

  create_table "achievement_rows", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "part_order", limit: 3, default: 0
    t.string "achievement_value", limit: 10
    t.boolean "is_bracket_open", default: false
    t.boolean "is_or_operator", default: false
    t.boolean "is_not_operator", default: false
    t.boolean "is_bracket_closed", default: false
    t.integer "achievement_id"
    t.integer "achievement_type_id"
    t.index ["achievement_id"], name: "idx_achievement_rows_achievement"
    t.index ["achievement_type_id"], name: "idx_achievement_rows_achievement_type"
  end

  create_table "achievement_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_achievement_types_on_code", unique: true
  end

  create_table "achievements", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 10
    t.integer "user_id"
    t.index ["code"], name: "index_achievements_on_code", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_grants", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "entity", limit: 150
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entity"], name: "index_admin_grants_on_entity"
    t.index ["user_id", "entity"], name: "index_admin_grants_on_user_id_and_entity", unique: true
    t.index ["user_id"], name: "index_admin_grants_on_user_id"
  end

  create_table "api_daily_uses", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "route", null: false
    t.date "day", null: false
    t.bigint "count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["route", "day"], name: "index_api_daily_uses_on_route_and_day", unique: true
    t.index ["route"], name: "index_api_daily_uses_on_route"
  end

  create_table "app_parameters", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "code"
    t.string "controller_name"
    t.string "action_name"
    t.boolean "is_a_post", default: false
    t.string "confirmation_text"
    t.string "a_string"
    t.boolean "a_bool"
    t.integer "a_integer"
    t.datetime "a_date"
    t.decimal "a_decimal", precision: 10, scale: 2
    t.decimal "a_decimal_2", precision: 10, scale: 2
    t.decimal "a_decimal_3", precision: 10, scale: 2
    t.decimal "a_decimal_4", precision: 10, scale: 2
    t.bigint "range_x"
    t.bigint "range_y"
    t.string "a_name"
    t.string "a_filename"
    t.string "tooltip_text"
    t.integer "view_height", default: 0
    t.bigint "code_type_1"
    t.bigint "code_type_2"
    t.bigint "code_type_3"
    t.bigint "code_type_4"
    t.text "free_text_1"
    t.text "free_text_2"
    t.text "free_text_3"
    t.text "free_text_4"
    t.boolean "free_bool_1"
    t.boolean "free_bool_2"
    t.boolean "free_bool_3"
    t.boolean "free_bool_4"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_app_parameters_on_code", unique: true
  end

  create_table "aux_arms_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_aux_arms_types_on_code", unique: true
  end

  create_table "aux_body_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_aux_body_types_on_code", unique: true
  end

  create_table "aux_breath_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_aux_breath_types_on_code", unique: true
  end

  create_table "aux_kicks_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_aux_kicks_types_on_code", unique: true
  end

  create_table "badge_payments", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.decimal "amount", precision: 10, scale: 2
    t.date "payment_date"
    t.text "notes"
    t.boolean "manual", default: false, null: false
    t.bigint "badge_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_badge_payments_on_badge_id"
    t.index ["user_id"], name: "index_badge_payments_on_user_id"
  end

  create_table "badges", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "number", limit: 40
    t.integer "season_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "category_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "entry_time_type_id"
    t.integer "team_affiliation_id"
    t.integer "final_rank"
    t.boolean "off_gogglecup", default: false
    t.boolean "fees_due", default: false, null: false
    t.boolean "badge_due", default: false, null: false
    t.boolean "relays_due", default: false, null: false
    t.index ["category_type_id"], name: "fk_badges_category_types"
    t.index ["entry_time_type_id"], name: "fk_badges_entry_time_types"
    t.index ["number"], name: "index_badges_on_number"
    t.index ["season_id"], name: "fk_badges_seasons"
    t.index ["swimmer_id"], name: "fk_badges_swimmers"
    t.index ["team_affiliation_id"], name: "fk_badges_team_affiliations"
    t.index ["team_id"], name: "fk_badges_teams"
  end

  create_table "base_movements", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.boolean "aux_arms_ok", default: false
    t.boolean "aux_kicks_ok", default: false
    t.boolean "aux_body_ok", default: false
    t.boolean "aux_breath_ok", default: false
    t.integer "movement_type_id"
    t.integer "stroke_type_id"
    t.integer "movement_scope_type_id"
    t.index ["code"], name: "index_base_movements_on_code", unique: true
    t.index ["movement_scope_type_id"], name: "fk_base_movements_movement_scope_types"
    t.index ["movement_type_id"], name: "fk_base_movements_movement_types"
    t.index ["stroke_type_id"], name: "fk_base_movements_stroke_types"
  end

  create_table "calendars", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "scheduled_date"
    t.string "meeting_name"
    t.string "meeting_place"
    t.string "manifest_code"
    t.string "startlist_code"
    t.string "results_code"
    t.string "meeting_code"
    t.integer "season_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "year", limit: 4
    t.string "month", limit: 20
    t.string "results_link"
    t.string "startlist_link"
    t.string "manifest_link"
    t.text "manifest"
    t.text "name_import_text"
    t.text "organization_import_text"
    t.text "place_import_text"
    t.text "dates_import_text"
    t.text "program_import_text"
    t.integer "meeting_id"
    t.boolean "read_only", default: false, null: false
    t.boolean "cancelled", default: false, null: false
    t.index ["cancelled"], name: "index_calendars_on_cancelled"
    t.index ["meeting_code"], name: "index_calendars_on_meeting_code"
    t.index ["meeting_id"], name: "index_calendars_on_meeting_id"
    t.index ["season_id"], name: "index_calendars_on_season_id"
  end

  create_table "category_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 7
    t.string "federation_code", limit: 2
    t.string "description", limit: 100
    t.string "short_name", limit: 50
    t.string "group_name", limit: 50
    t.integer "age_begin", limit: 3
    t.integer "age_end", limit: 3
    t.boolean "relay", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "season_id"
    t.boolean "out_of_race", default: false
    t.boolean "undivided", default: false, null: false
    t.index ["federation_code", "relay"], name: "federation_code"
    t.index ["season_id", "relay", "code"], name: "season_and_code", unique: true
  end

  create_table "cities", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "name", limit: 50
    t.string "zip", limit: 6
    t.string "area", limit: 50
    t.string "country", limit: 50
    t.string "country_code", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "latitude", limit: 50
    t.string "longitude", limit: 50
    t.string "plus_code", limit: 50
    t.index ["country_code", "area", "name"], name: "index_cities_on_country_code_and_area_and_name", unique: true
    t.index ["name", "area"], name: "city_name", type: :fulltext
    t.index ["name"], name: "index_cities_on_name"
  end

  create_table "coach_level_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.integer "level", limit: 3, default: 0
    t.index ["code"], name: "index_coach_level_types_on_code", unique: true
  end

  create_table "comments", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "entry_text"
    t.integer "user_id"
    t.integer "swimming_pool_review_id"
    t.integer "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["comment_id"], name: "fk_comments_comments"
    t.index ["swimming_pool_review_id"], name: "fk_comments_swimming_pool_reviews"
    t.index ["user_id"], name: "idx_comments_user"
  end

  create_table "computed_season_rankings", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 0
    t.decimal "total_points", precision: 10, scale: 2, default: "0.0"
    t.integer "team_id"
    t.integer "season_id"
    t.index ["season_id", "rank"], name: "rank_x_season"
    t.index ["season_id", "team_id"], name: "teams_x_season"
    t.index ["team_id"], name: "fk_computed_season_rankings_teams"
  end

  create_table "data_import_swimmer_aliases", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "complete_name", limit: 100
    t.integer "swimmer_id"
    t.index ["swimmer_id", "complete_name"], name: "idx_swimmer_id_complete_name", unique: true
  end

  create_table "data_import_team_aliases", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 60
    t.integer "team_id"
    t.index ["team_id", "name"], name: "idx_team_id_name", unique: true
  end

  create_table "day_part_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.index ["code"], name: "index_day_part_types_on_code", unique: true
  end

  create_table "day_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.integer "week_order", limit: 3, default: 0
    t.index ["code"], name: "index_day_types_on_code", unique: true
  end

  create_table "delayed_jobs", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "disqualification_code_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 4
    t.boolean "relay", default: false
    t.integer "stroke_type_id"
    t.index ["relay", "code"], name: "code", unique: true
    t.index ["relay"], name: "index_disqualification_code_types_on_relay"
    t.index ["stroke_type_id"], name: "idx_disqualification_code_types_stroke_type"
  end

  create_table "edition_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.index ["code"], name: "index_edition_types_on_code", unique: true
  end

  create_table "entry_time_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "idx_entry_time_types_code", unique: true
  end

  create_table "event_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 10
    t.bigint "length_in_meters"
    t.boolean "relay", default: false
    t.integer "stroke_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "style_order", limit: 2, default: 0
    t.boolean "mixed_gender", default: false
    t.integer "partecipants", limit: 2, default: 4
    t.integer "phases", limit: 2, default: 4
    t.integer "phase_length_in_meters", limit: 3, default: 50
    t.index ["relay", "code"], name: "code", unique: true
    t.index ["relay"], name: "index_event_types_on_relay"
    t.index ["stroke_type_id"], name: "fk_event_types_stroke_types"
    t.index ["style_order"], name: "index_event_types_on_style_order"
  end

  create_table "events_by_pool_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "pool_type_id"
    t.integer "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_type_id"], name: "fk_events_by_pool_types_event_types"
    t.index ["pool_type_id"], name: "fk_events_by_pool_types_pool_types"
  end

  create_table "execution_note_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 3
    t.index ["code"], name: "index_execution_note_types_on_code", unique: true
  end

  create_table "exercise_rows", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "part_order", limit: 3, default: 0
    t.integer "percentage", limit: 3, default: 0
    t.integer "start_and_rest", default: 0
    t.integer "pause", default: 0
    t.integer "exercise_id"
    t.integer "base_movement_id"
    t.integer "training_mode_type_id"
    t.integer "execution_note_type_id"
    t.integer "length_in_meters", default: 0
    t.index ["base_movement_id"], name: "fk_exercise_rows_base_movements"
    t.index ["execution_note_type_id"], name: "fk_exercise_rows_execution_note_types"
    t.index ["exercise_id", "part_order"], name: "idx_exercise_rows_part_order"
    t.index ["training_mode_type_id"], name: "fk_exercise_rows_training_mode_types"
  end

  create_table "exercises", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.string "training_step_type_codes", limit: 50
    t.index ["code"], name: "index_exercises_on_code", unique: true
  end

  create_table "federation_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 4
    t.string "description", limit: 100
    t.string "short_name", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_federation_types_on_code", unique: true
  end

  create_table "friendships", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "friendable_id"
    t.integer "friend_id"
    t.integer "blocker_id"
    t.boolean "pending", default: true
    t.boolean "shares_passages", default: false
    t.boolean "shares_trainings", default: false
    t.boolean "shares_calendars", default: false
    t.index ["friendable_id", "friend_id"], name: "index_friendships_on_friendable_id_and_friend_id", unique: true
  end

  create_table "gender_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_gender_types_on_code", unique: true
  end

  create_table "goggle_cup_definitions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "goggle_cup_id"
    t.integer "season_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["goggle_cup_id"], name: "fk_goggle_cup_definitions_goggle_cups"
    t.index ["season_id"], name: "fk_goggle_cup_definitions_seasons"
  end

  create_table "goggle_cup_standards", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.integer "event_type_id"
    t.integer "pool_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.integer "goggle_cup_id"
    t.integer "swimmer_id"
    t.index ["event_type_id"], name: "fk_goggle_cup_standards_event_types"
    t.index ["goggle_cup_id", "swimmer_id", "pool_type_id", "event_type_id"], name: "idx_goggle_cup_standards_goggle_cup_swimmer_pool_event", unique: true
    t.index ["goggle_cup_id"], name: "fk_goggle_cup_standards_goggle_cups"
    t.index ["pool_type_id"], name: "fk_goggle_cup_standards_pool_types"
    t.index ["swimmer_id"], name: "fk_goggle_cup_standards_swimmers"
  end

  create_table "goggle_cups", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "description", limit: 60
    t.integer "season_year", default: 2010
    t.integer "max_points", default: 1000
    t.integer "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "max_performance", limit: 2, default: 5
    t.boolean "limited_to_existing_season_types", default: false, null: false
    t.date "end_date"
    t.integer "age_for_negative_modifier", default: 20
    t.decimal "negative_modifier", precision: 10, scale: 2, default: "-10.0"
    t.integer "age_for_positive_modifier", default: 60
    t.decimal "positive_modifier", precision: 10, scale: 2, default: "5.0"
    t.boolean "create_standards", default: true
    t.boolean "update_standards", default: false
    t.text "pre_calculation_sql"
    t.text "post_calculation_sql"
    t.boolean "team_constrained", default: true
    t.integer "career_step", default: 100
    t.decimal "career_bonus", precision: 10, scale: 2, default: "0.0"
    t.index ["season_year"], name: "idx_season_year"
    t.index ["team_id"], name: "fk_goggle_cups_teams"
  end

  create_table "hair_dryer_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_hair_dryer_types_on_code", unique: true
  end

  create_table "heat_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "default", default: false
    t.index ["code"], name: "idx_heat_types_code", unique: true
  end

  create_table "import_queues", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.bigint "user_id", null: false
    t.integer "process_runs", default: 0
    t.text "request_data", null: false
    t.text "solved_data", null: false
    t.boolean "done", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uid"
    t.integer "bindings_left_count", default: 0, null: false
    t.string "bindings_left_list"
    t.text "error_messages"
    t.integer "import_queue_id"
    t.boolean "batch_sql", default: false, null: false
    t.index ["batch_sql"], name: "index_import_queues_on_batch_sql"
    t.index ["done"], name: "index_import_queues_on_done"
    t.index ["import_queue_id"], name: "index_import_queues_on_import_queue_id"
    t.index ["user_id", "uid"], name: "index_import_queues_on_user_id_and_uid"
    t.index ["user_id"], name: "index_import_queues_on_user_id"
  end

  create_table "individual_records", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "pool_type_id"
    t.integer "event_type_id"
    t.integer "category_type_id"
    t.integer "gender_type_id"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.boolean "team_record", default: false
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "season_id"
    t.integer "federation_type_id"
    t.integer "meeting_individual_result_id"
    t.integer "record_type_id"
    t.index ["category_type_id"], name: "idx_individual_records_category_type"
    t.index ["event_type_id"], name: "idx_individual_records_event_type"
    t.index ["federation_type_id"], name: "idx_individual_records_federation_type"
    t.index ["gender_type_id"], name: "idx_individual_records_gender_type"
    t.index ["meeting_individual_result_id"], name: "idx_individual_records_meeting_individual_result"
    t.index ["pool_type_id"], name: "idx_individual_records_pool_type"
    t.index ["record_type_id"], name: "fk_individual_records_record_types"
    t.index ["season_id"], name: "idx_individual_records_season"
    t.index ["swimmer_id"], name: "idx_individual_records_swimmer"
    t.index ["team_id"], name: "idx_individual_records_team"
  end

  create_table "issues", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "code", limit: 3, null: false
    t.text "req", null: false
    t.integer "priority", limit: 1, default: 0
    t.integer "status", limit: 1, default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_issues_on_code"
    t.index ["priority"], name: "index_issues_on_priority"
    t.index ["status"], name: "index_issues_on_status"
    t.index ["user_id"], name: "index_issues_on_user_id"
  end

  create_table "laps", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.integer "meeting_program_id"
    t.integer "length_in_meters"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "reaction_time", precision: 5, scale: 2
    t.integer "stroke_cycles", limit: 3
    t.integer "underwater_seconds", limit: 2
    t.integer "underwater_hundredths", limit: 2
    t.integer "underwater_kicks", limit: 2
    t.integer "breath_cycles", limit: 3
    t.integer "position", limit: 3
    t.integer "minutes_from_start", limit: 3
    t.integer "seconds_from_start", limit: 2
    t.integer "hundredths_from_start", limit: 2
    t.integer "meeting_individual_result_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.index ["length_in_meters"], name: "index_laps_on_length_in_meters"
    t.index ["meeting_individual_result_id"], name: "idx_passages_meeting_individual_result"
    t.index ["meeting_program_id"], name: "passages_x_badges"
    t.index ["swimmer_id"], name: "idx_passages_swimmer"
    t.index ["team_id"], name: "idx_passages_team"
  end

  create_table "locker_cabinet_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_locker_cabinet_types_on_code", unique: true
  end

  create_table "managed_affiliations", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "team_affiliation_id"
    t.integer "user_id"
    t.index ["team_affiliation_id", "user_id"], name: "team_manager_with_affiliation", unique: true
    t.index ["team_affiliation_id"], name: "index_managed_affiliations_on_team_affiliation_id"
    t.index ["user_id"], name: "index_managed_affiliations_on_user_id"
  end

  create_table "medal_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 0
    t.integer "weigth", default: 0
    t.string "image_uri", limit: 50
    t.index ["code"], name: "index_medal_types_on_code", unique: true
  end

  create_table "meeting_entries", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "start_list_number"
    t.integer "lane_number", limit: 2
    t.integer "heat_number"
    t.integer "heat_arrival_order", limit: 2
    t.integer "meeting_program_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "team_affiliation_id"
    t.integer "badge_id"
    t.integer "entry_time_type_id"
    t.integer "minutes", limit: 3
    t.integer "seconds", limit: 2
    t.integer "hundredths", limit: 2
    t.boolean "no_time", default: false
    t.index ["badge_id"], name: "idx_meeting_entries_badge"
    t.index ["entry_time_type_id"], name: "idx_meeting_entries_entry_time_type"
    t.index ["meeting_program_id"], name: "idx_meeting_entries_meeting_program"
    t.index ["swimmer_id"], name: "idx_meeting_entries_swimmer"
    t.index ["team_affiliation_id"], name: "idx_meeting_entries_team_affiliation"
    t.index ["team_id"], name: "idx_meeting_entries_team"
  end

  create_table "meeting_event_reservations", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "meeting_id"
    t.integer "team_id"
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.integer "meeting_event_id"
    t.integer "minutes", limit: 3
    t.integer "seconds", limit: 2
    t.integer "hundredths", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "accepted", default: false, null: false
    t.bigint "meeting_reservation_id"
    t.index ["badge_id"], name: "index_meeting_event_reservations_on_badge_id"
    t.index ["meeting_event_id"], name: "index_meeting_event_reservations_on_meeting_event_id"
    t.index ["meeting_id", "badge_id", "team_id", "swimmer_id", "meeting_event_id"], name: "idx_unique_event_reservation", unique: true
    t.index ["meeting_id"], name: "index_meeting_event_reservations_on_meeting_id"
    t.index ["meeting_reservation_id"], name: "index_meeting_event_reservations_on_meeting_reservation_id"
    t.index ["swimmer_id"], name: "index_meeting_event_reservations_on_swimmer_id"
    t.index ["team_id"], name: "index_meeting_event_reservations_on_team_id"
  end

  create_table "meeting_events", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_order", limit: 3, default: 0
    t.time "begin_time"
    t.boolean "out_of_race", default: false
    t.boolean "autofilled", default: false
    t.text "notes"
    t.integer "meeting_session_id"
    t.integer "event_type_id"
    t.integer "heat_type_id"
    t.boolean "split_gender_start_list", default: true
    t.boolean "split_category_start_list", default: false
    t.index ["event_type_id"], name: "fk_meeting_events_event_types"
    t.index ["heat_type_id"], name: "fk_meeting_events_heat_types"
    t.index ["meeting_session_id"], name: "fk_meeting_events_meeting_sessions"
  end

  create_table "meeting_individual_results", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "rank", default: 0
    t.boolean "play_off", default: false
    t.boolean "out_of_race", default: false
    t.boolean "disqualified", default: false
    t.decimal "standard_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_points", precision: 10, scale: 2, default: "0.0"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.integer "meeting_program_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "badge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "disqualification_code_type_id"
    t.decimal "goggle_cup_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.decimal "team_points", precision: 10, scale: 2, default: "0.0"
    t.integer "team_affiliation_id"
    t.boolean "personal_best", default: false, null: false
    t.boolean "season_type_best", default: false, null: false
    t.string "disqualification_notes"
    t.index ["badge_id"], name: "fk_meeting_individual_results_badges"
    t.index ["disqualification_code_type_id"], name: "idx_mir_disqualification_code_type"
    t.index ["disqualified"], name: "index_meeting_individual_results_on_disqualified"
    t.index ["meeting_program_id"], name: "fk_meeting_individual_results_meeting_programs"
    t.index ["out_of_race"], name: "index_meeting_individual_results_on_out_of_race"
    t.index ["personal_best"], name: "index_meeting_individual_results_on_personal_best"
    t.index ["season_type_best"], name: "index_meeting_individual_results_on_season_type_best"
    t.index ["swimmer_id"], name: "fk_meeting_individual_results_swimmers"
    t.index ["team_affiliation_id"], name: "fk_meeting_individual_results_team_affiliations"
    t.index ["team_id"], name: "fk_meeting_individual_results_teams"
    t.index ["updated_at"], name: "idx_meeting_individual_results_updated_at"
  end

  create_table "meeting_programs", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "event_order", limit: 3, default: 0
    t.integer "category_type_id"
    t.integer "gender_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "autofilled", default: false
    t.boolean "out_of_race", default: false
    t.time "begin_time"
    t.integer "meeting_event_id"
    t.integer "pool_type_id"
    t.integer "standard_timing_id"
    t.index ["category_type_id"], name: "meeting_category_type"
    t.index ["event_order"], name: "meeting_order"
    t.index ["gender_type_id"], name: "meeting_gender_type"
    t.index ["meeting_event_id"], name: "fk_meeting_programs_meeting_events"
    t.index ["pool_type_id"], name: "fk_meeting_programs_pool_types"
    t.index ["standard_timing_id"], name: "fk_meeting_programs_time_standards"
  end

  create_table "meeting_relay_reservations", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "meeting_id"
    t.integer "team_id"
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.integer "meeting_event_id"
    t.string "notes", limit: 50
    t.boolean "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "meeting_reservation_id"
    t.index ["badge_id"], name: "index_meeting_relay_reservations_on_badge_id"
    t.index ["meeting_event_id"], name: "index_meeting_relay_reservations_on_meeting_event_id"
    t.index ["meeting_id", "badge_id", "team_id", "swimmer_id", "meeting_event_id"], name: "idx_unique_relay_reservation", unique: true
    t.index ["meeting_id"], name: "index_meeting_relay_reservations_on_meeting_id"
    t.index ["meeting_reservation_id"], name: "index_meeting_relay_reservations_on_meeting_reservation_id"
    t.index ["swimmer_id"], name: "index_meeting_relay_reservations_on_swimmer_id"
    t.index ["team_id"], name: "index_meeting_relay_reservations_on_team_id"
  end

  create_table "meeting_relay_results", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 0
    t.boolean "play_off", default: false
    t.boolean "out_of_race", default: false
    t.boolean "disqualified", default: false
    t.decimal "standard_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_points", precision: 10, scale: 2, default: "0.0"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.integer "team_id"
    t.integer "meeting_program_id"
    t.integer "disqualification_code_type_id"
    t.string "relay_code", limit: 60, default: ""
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.integer "entry_minutes", limit: 3
    t.integer "entry_seconds", limit: 2
    t.integer "entry_hundredths", limit: 2
    t.integer "team_affiliation_id"
    t.integer "entry_time_type_id"
    t.string "disqualification_notes"
    t.integer "meeting_relay_swimmers_count", default: 0, null: false
    t.index ["disqualification_code_type_id"], name: "idx_mrr_disqualification_code_type"
    t.index ["entry_time_type_id"], name: "fk_meeting_relay_results_entry_time_types"
    t.index ["meeting_program_id", "rank"], name: "results_x_relay"
    t.index ["team_affiliation_id"], name: "fk_meeting_relay_results_team_affiliations"
    t.index ["team_id"], name: "fk_meeting_relay_results_teams"
  end

  create_table "meeting_relay_swimmers", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "relay_order", limit: 3, default: 0
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.integer "stroke_type_id"
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.integer "meeting_relay_result_id"
    t.integer "length_in_meters", default: 0, null: false
    t.integer "minutes_from_start", limit: 3, default: 0, null: false
    t.integer "seconds_from_start", limit: 2, default: 0, null: false
    t.integer "hundredths_from_start", limit: 2, default: 0, null: false
    t.integer "relay_laps_count", default: 0, null: false
    t.index ["badge_id"], name: "fk_meeting_relay_swimmers_badges"
    t.index ["length_in_meters"], name: "index_meeting_relay_swimmers_on_length_in_meters"
    t.index ["meeting_relay_result_id"], name: "fk_meeting_relay_swimmers_meeting_relay_results"
    t.index ["relay_order"], name: "relay_order"
    t.index ["stroke_type_id"], name: "fk_meeting_relay_swimmers_stroke_types"
    t.index ["swimmer_id"], name: "fk_meeting_relay_swimmers_swimmers"
  end

  create_table "meeting_reservations", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "meeting_id"
    t.integer "user_id"
    t.integer "team_id"
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.text "notes"
    t.boolean "not_coming"
    t.boolean "confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "payed", default: false, null: false
    t.index ["badge_id"], name: "index_meeting_reservations_on_badge_id"
    t.index ["meeting_id", "badge_id"], name: "idx_unique_reservation", unique: true
    t.index ["meeting_id"], name: "index_meeting_reservations_on_meeting_id"
    t.index ["payed"], name: "index_meeting_reservations_on_payed"
    t.index ["swimmer_id"], name: "index_meeting_reservations_on_swimmer_id"
    t.index ["team_id"], name: "index_meeting_reservations_on_team_id"
    t.index ["user_id"], name: "index_meeting_reservations_on_user_id"
  end

  create_table "meeting_sessions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "session_order", limit: 2, default: 0
    t.date "scheduled_date"
    t.time "warm_up_time"
    t.time "begin_time"
    t.text "notes"
    t.integer "meeting_id"
    t.integer "swimming_pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description", limit: 100
    t.boolean "autofilled", default: false
    t.integer "day_part_type_id"
    t.index ["day_part_type_id"], name: "fk_meeting_sessions_day_part_types"
    t.index ["meeting_id"], name: "fk_meeting_sessions_meetings"
    t.index ["scheduled_date"], name: "index_meeting_sessions_on_scheduled_date"
    t.index ["swimming_pool_id"], name: "fk_meeting_sessions_swimming_pools"
  end

  create_table "meeting_team_scores", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.decimal "sum_individual_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "sum_relay_points", precision: 10, scale: 2, default: "0.0"
    t.integer "team_id"
    t.integer "meeting_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 0
    t.decimal "sum_team_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_relay_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_team_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_relay_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_team_points", precision: 10, scale: 2, default: "0.0"
    t.integer "season_id"
    t.integer "team_affiliation_id"
    t.index ["meeting_id", "team_id"], name: "teams_x_meeting"
    t.index ["season_id"], name: "fk_meeting_team_scores_seasons"
    t.index ["team_affiliation_id"], name: "fk_meeting_team_scores_team_affiliations"
    t.index ["team_id"], name: "fk_meeting_team_scores_teams"
  end

  create_table "meetings", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "description", limit: 100
    t.date "entry_deadline"
    t.boolean "warm_up_pool", default: false
    t.boolean "allows_under25", default: false
    t.string "reference_phone", limit: 40
    t.string "reference_e_mail", limit: 50
    t.string "reference_name", limit: 50
    t.text "notes"
    t.boolean "manifest", default: false
    t.boolean "startlist", default: false
    t.boolean "results_acquired", default: false
    t.integer "max_individual_events", limit: 1, default: 2
    t.string "configuration_file"
    t.integer "edition", limit: 3, default: 0
    t.integer "season_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "autofilled", default: false
    t.date "header_date"
    t.string "code", limit: 50
    t.string "header_year", limit: 9
    t.integer "max_individual_events_per_session", limit: 2, default: 2
    t.boolean "off_season", default: false
    t.integer "edition_type_id"
    t.integer "timing_type_id"
    t.integer "individual_score_computation_type_id"
    t.integer "relay_score_computation_type_id"
    t.integer "team_score_computation_type_id"
    t.integer "meeting_score_computation_type_id"
    t.text "manifest_body", size: :medium
    t.boolean "confirmed", default: false, null: false
    t.boolean "tweeted", default: false
    t.boolean "posted", default: false
    t.boolean "cancelled", default: false
    t.boolean "pb_acquired", default: false
    t.bigint "home_team_id"
    t.boolean "read_only", default: false, null: false
    t.decimal "meeting_fee", precision: 10, scale: 2
    t.decimal "event_fee", precision: 10, scale: 2
    t.decimal "relay_fee", precision: 10, scale: 2
    t.index ["code", "edition"], name: "idx_meetings_code"
    t.index ["code"], name: "meeting_code", type: :fulltext
    t.index ["description", "code"], name: "meeting_name", type: :fulltext
    t.index ["description"], name: "meeting_desc", type: :fulltext
    t.index ["edition_type_id"], name: "fk_meetings_edition_types"
    t.index ["entry_deadline"], name: "index_meetings_on_entry_deadline"
    t.index ["header_date"], name: "idx_meetings_header_date"
    t.index ["home_team_id"], name: "index_meetings_on_home_team_id"
    t.index ["individual_score_computation_type_id"], name: "fk_meetings_score_individual_score_computation_types"
    t.index ["meeting_score_computation_type_id"], name: "fk_meetings_score_meeting_score_computation_types"
    t.index ["relay_score_computation_type_id"], name: "fk_meetings_score_relay_score_computation_types"
    t.index ["season_id"], name: "fk_meetings_seasons"
    t.index ["team_score_computation_type_id"], name: "fk_meetings_score_team_score_computation_types"
    t.index ["timing_type_id"], name: "fk_meetings_timing_types"
  end

  create_table "movement_scope_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.index ["code"], name: "index_movement_scope_types_on_code", unique: true
  end

  create_table "movement_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.index ["code"], name: "index_movement_types_on_code", unique: true
  end

  create_table "pool_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.integer "length_in_meters", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "eventable", default: true
    t.index ["code"], name: "index_pool_types_on_code", unique: true
  end

  create_table "posts", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "title", limit: 80
    t.text "body"
    t.boolean "pinned", default: false
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["title"], name: "index_posts_on_title"
    t.index ["user_id"], name: "idx_articles_user"
  end

  create_table "presence_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.integer "value", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_presence_types_on_code", unique: true
  end

  create_table "rails_admin_histories", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.text "message"
    t.string "username"
    t.integer "item"
    t.string "table"
    t.integer "month", limit: 2
    t.bigint "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item", "table", "month", "year"], name: "index_rails_admin_histories"
  end

  create_table "record_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "swimmer", default: false
    t.boolean "team", default: false
    t.boolean "season", default: false
    t.index ["code"], name: "index_record_types_on_code", unique: true
  end

  create_table "relay_laps", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.integer "minutes_from_start", limit: 3, default: 0
    t.integer "seconds_from_start", limit: 2, default: 0
    t.integer "hundredths_from_start", limit: 2, default: 0
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.integer "length_in_meters", default: 0
    t.integer "position", limit: 3
    t.integer "stroke_cycles"
    t.integer "breath_cycles"
    t.integer "swimmer_id", null: false
    t.integer "team_id", null: false
    t.integer "meeting_relay_result_id", null: false
    t.integer "meeting_relay_swimmer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meeting_relay_result_id"], name: "index_relay_laps_on_meeting_relay_result_id"
    t.index ["meeting_relay_swimmer_id"], name: "index_relay_laps_on_meeting_relay_swimmer_id"
    t.index ["swimmer_id"], name: "index_relay_laps_on_swimmer_id"
    t.index ["team_id"], name: "index_relay_laps_on_team_id"
  end

  create_table "score_computation_type_rows", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "class_name", limit: 100
    t.string "method_name", limit: 100
    t.decimal "default_score", precision: 10, scale: 2, default: "0.0"
    t.integer "score_computation_type_id"
    t.integer "score_mapping_type_id"
    t.bigint "computation_order", default: 0
    t.integer "position_limit", default: 0
    t.index ["computation_order"], name: "idx_score_computation_type_rows_computation_order"
    t.index ["score_computation_type_id"], name: "fk_score_computation_type_rows_score_computation_types"
    t.index ["score_mapping_type_id"], name: "idx_score_computation_type_rows_score_mapping_type"
  end

  create_table "score_computation_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.index ["code"], name: "index_score_computation_types_on_code", unique: true
  end

  create_table "score_mapping_type_rows", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "position", default: 0
    t.decimal "score", precision: 10, scale: 2, default: "0.0"
    t.integer "score_mapping_type_id"
    t.index ["score_mapping_type_id"], name: "idx_score_mapping_type_rows_score_mapping_type"
  end

  create_table "score_mapping_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.index ["code"], name: "index_score_mapping_types_on_code", unique: true
  end

  create_table "season_personal_standards", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "minutes", limit: 3, default: 0, null: false
    t.integer "seconds", limit: 2, default: 0, null: false
    t.integer "hundredths", limit: 2, default: 0, null: false
    t.integer "season_id"
    t.integer "swimmer_id"
    t.integer "event_type_id"
    t.integer "pool_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id", "swimmer_id", "pool_type_id", "event_type_id"], name: "idx_season_personal_standards_season_swimmer_event_pool", unique: true
    t.index ["season_id"], name: "idx_season_personal_standards_season_id"
    t.index ["swimmer_id"], name: "idx_season_personal_standards_swimmer_id"
  end

  create_table "season_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 10
    t.string "description", limit: 100
    t.string "short_name", limit: 40
    t.integer "federation_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_season_types_on_code", unique: true
    t.index ["federation_type_id"], name: "fk_season_types_federation_types"
  end

  create_table "seasons", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "description", limit: 100
    t.date "begin_date"
    t.date "end_date"
    t.integer "season_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "header_year", limit: 9
    t.integer "edition", limit: 3, default: 0
    t.integer "edition_type_id"
    t.integer "timing_type_id"
    t.text "rules", size: :medium
    t.boolean "individual_rank", default: true
    t.decimal "badge_fee", precision: 10, scale: 2
    t.index ["begin_date"], name: "index_seasons_on_begin_date"
    t.index ["edition_type_id"], name: "fk_seasons_edition_types"
    t.index ["season_type_id"], name: "fk_seasons_season_types"
    t.index ["timing_type_id"], name: "fk_seasons_timing_types"
  end

  create_table "sessions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "session_id", collation: "latin1_swedish_ci"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "var", null: false, collation: "latin1_swedish_ci"
    t.text "value"
    t.string "target_type", null: false, collation: "latin1_swedish_ci"
    t.integer "target_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true
    t.index ["target_type", "target_id"], name: "index_settings_on_target_type_and_target_id"
  end

  create_table "shower_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_shower_types_on_code", unique: true
  end

  create_table "social_news", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title", limit: 150
    t.text "body"
    t.boolean "old", default: false
    t.boolean "friend_activity", default: false
    t.boolean "achievement", default: false
    t.integer "user_id"
    t.integer "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "idx_news_feeds_user"
  end

  create_table "standard_timings", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.integer "season_id"
    t.integer "gender_type_id"
    t.integer "pool_type_id"
    t.integer "event_type_id"
    t.integer "category_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_type_id"], name: "fk_time_standards_category_types"
    t.index ["event_type_id"], name: "fk_time_standards_event_types"
    t.index ["gender_type_id"], name: "fk_time_standards_gender_types"
    t.index ["pool_type_id"], name: "fk_time_standards_pool_types"
    t.index ["season_id"], name: "fk_time_standards_seasons"
  end

  create_table "stroke_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "eventable", default: false
    t.index ["code"], name: "index_stroke_types_on_code", unique: true
    t.index ["eventable"], name: "idx_is_eventable"
  end

  create_table "swimmer_level_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.integer "level", limit: 3, default: 0
    t.integer "achievement_id"
    t.index ["achievement_id"], name: "idx_swimmer_level_types_achievement"
    t.index ["code"], name: "index_swimmer_level_types_on_code", unique: true
  end

  create_table "swimmer_season_scores", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.decimal "score", precision: 10, scale: 2
    t.integer "badge_id"
    t.integer "meeting_individual_result_id"
    t.integer "event_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id", "event_type_id"], name: "swimmer_season_scores_badge_event"
    t.index ["badge_id", "score"], name: "swimmer_season_scores_badge_score"
    t.index ["badge_id"], name: "index_swimmer_season_scores_on_badge_id"
    t.index ["event_type_id"], name: "index_swimmer_season_scores_on_event_type_id"
    t.index ["meeting_individual_result_id"], name: "index_swimmer_season_scores_on_meeting_individual_result_id"
  end

  create_table "swimmers", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "last_name", limit: 50
    t.string "first_name", limit: 50
    t.integer "year_of_birth", default: 1900
    t.string "phone_mobile", limit: 40
    t.string "phone_number", limit: 40
    t.string "e_mail", limit: 100
    t.string "nickname", limit: 25, default: ""
    t.bigint "associated_user_id"
    t.integer "gender_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "complete_name", limit: 100
    t.boolean "year_guessed", default: false
    t.index ["associated_user_id"], name: "index_swimmers_on_associated_user_id"
    t.index ["complete_name", "year_of_birth"], name: "name_and_year", unique: true
    t.index ["complete_name"], name: "index_swimmers_on_complete_name"
    t.index ["complete_name"], name: "swimmer_complete_name", type: :fulltext
    t.index ["first_name"], name: "swimmer_first_name", type: :fulltext
    t.index ["gender_type_id"], name: "fk_swimmers_gender_types"
    t.index ["last_name", "first_name", "complete_name"], name: "swimmer_name", type: :fulltext
    t.index ["last_name", "first_name"], name: "full_name"
    t.index ["last_name"], name: "swimmer_last_name", type: :fulltext
    t.index ["nickname"], name: "index_swimmers_on_nickname"
  end

  create_table "swimming_pool_reviews", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "title", limit: 100
    t.text "entry_text"
    t.integer "user_id"
    t.integer "swimming_pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["swimming_pool_id"], name: "fk_swimming_pool_reviews_swimming_pools"
    t.index ["title"], name: "index_swimming_pool_reviews_on_title"
    t.index ["user_id"], name: "idx_swimming_pool_reviews_user"
  end

  create_table "swimming_pools", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "name", limit: 100
    t.string "address", limit: 100
    t.string "zip", limit: 6
    t.string "nick_name", limit: 50
    t.string "phone_number", limit: 40
    t.string "fax_number", limit: 40
    t.string "e_mail", limit: 100
    t.string "contact_name", limit: 100
    t.string "maps_uri"
    t.integer "lanes_number", limit: 2, default: 8
    t.boolean "multiple_pools", default: false
    t.boolean "garden", default: false
    t.boolean "bar", default: false
    t.boolean "restaurant", default: false
    t.boolean "gym", default: false
    t.boolean "child_area", default: false
    t.text "notes"
    t.integer "city_id"
    t.integer "pool_type_id"
    t.integer "shower_type_id"
    t.integer "hair_dryer_type_id"
    t.integer "locker_cabinet_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "read_only", default: false, null: false
    t.string "latitude", limit: 50
    t.string "longitude", limit: 50
    t.string "plus_code", limit: 50
    t.index ["city_id"], name: "fk_swimming_pools_cities"
    t.index ["hair_dryer_type_id"], name: "fk_swimming_pools_hair_dryer_types"
    t.index ["locker_cabinet_type_id"], name: "fk_swimming_pools_locker_cabinet_types"
    t.index ["name", "nick_name"], name: "swimming_pool_name", type: :fulltext
    t.index ["name"], name: "index_swimming_pools_on_name"
    t.index ["nick_name"], name: "index_swimming_pools_on_nick_name", unique: true
    t.index ["pool_type_id"], name: "fk_swimming_pools_pool_types"
    t.index ["shower_type_id"], name: "fk_swimming_pools_shower_types"
  end

  create_table "taggings", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "name", collation: "utf8mb3_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "team_affiliations", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "number", limit: 20
    t.string "name", limit: 100
    t.boolean "compute_gogglecup", default: false
    t.integer "team_id"
    t.integer "season_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "autofilled", default: false
    t.index ["name"], name: "index_team_affiliations_on_name"
    t.index ["name"], name: "team_affiliation_name", type: :fulltext
    t.index ["number"], name: "index_team_affiliations_on_number"
    t.index ["season_id", "team_id"], name: "uk_team_affiliations_seasons_teams", unique: true
    t.index ["team_id"], name: "fk_team_affiliations_teams"
  end

  create_table "team_lap_templates", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "part_order", limit: 3, default: 0
    t.boolean "subtotal", default: false
    t.boolean "cycle_count", default: false
    t.boolean "breath_count", default: false
    t.boolean "underwater_part", default: false
    t.boolean "underwater_kicks", default: false
    t.boolean "lap_position", default: false
    t.integer "team_id"
    t.integer "event_type_id"
    t.integer "pool_type_id"
    t.integer "length_in_meters"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_type_id"], name: "idx_team_passage_templates_event_type"
    t.index ["length_in_meters"], name: "index_team_lap_templates_on_length_in_meters"
    t.index ["pool_type_id"], name: "idx_team_passage_templates_pool_type"
    t.index ["team_id"], name: "idx_team_passage_templates_team"
  end

  create_table "teams", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "name", limit: 60
    t.string "editable_name", limit: 60
    t.string "address", limit: 100
    t.string "zip", limit: 6
    t.string "phone_mobile", limit: 40
    t.string "phone_number", limit: 40
    t.string "fax_number", limit: 40
    t.string "e_mail", limit: 100
    t.string "contact_name", limit: 100
    t.text "notes"
    t.text "name_variations"
    t.integer "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "home_page_url", limit: 150
    t.index ["city_id"], name: "fk_teams_cities"
    t.index ["editable_name"], name: "index_teams_on_editable_name"
    t.index ["editable_name"], name: "team_editable_name", type: :fulltext
    t.index ["name", "editable_name", "name_variations"], name: "team_name", type: :fulltext
    t.index ["name"], name: "index_teams_on_name"
    t.index ["name"], name: "team_only_name", type: :fulltext
    t.index ["name_variations"], name: "team_name_variations", type: :fulltext
  end

  create_table "timing_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_timing_types_on_code", unique: true
  end

  create_table "training_mode_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_training_mode_types_on_code", unique: true
  end

  create_table "training_rows", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "part_order", limit: 3, default: 0
    t.integer "times", limit: 3, default: 0
    t.integer "distance", default: 0
    t.integer "start_and_rest", default: 0
    t.integer "pause", default: 0
    t.integer "training_id"
    t.integer "exercise_id"
    t.integer "training_step_type_id"
    t.integer "group_id", limit: 3, default: 0
    t.integer "group_times", limit: 3, default: 0
    t.integer "group_start_and_rest", default: 0
    t.integer "group_pause", default: 0
    t.integer "aux_arms_type_id"
    t.integer "aux_kicks_type_id"
    t.integer "aux_body_type_id"
    t.integer "aux_breath_type_id"
    t.index ["aux_arms_type_id"], name: "fk_training_rows_arm_aux_types"
    t.index ["aux_body_type_id"], name: "fk_training_rows_body_aux_types"
    t.index ["aux_breath_type_id"], name: "fk_training_rows_breath_aux_types"
    t.index ["aux_kicks_type_id"], name: "fk_training_rows_kick_aux_types"
    t.index ["exercise_id"], name: "fk_training_exercises"
    t.index ["group_id", "part_order"], name: "index_training_rows_on_group_id_and_part_order"
    t.index ["training_id", "part_order"], name: "idx_training_rows_part_order"
    t.index ["training_step_type_id"], name: "fk_training_rows_training_step_types"
  end

  create_table "training_step_types", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.integer "step_order", limit: 3, default: 0
    t.index ["code"], name: "index_training_step_types_on_code", unique: true
    t.index ["step_order"], name: "index_training_step_types_on_step_order"
  end

  create_table "trainings", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title", limit: 100, default: ""
    t.text "description"
    t.integer "min_swimmer_level", limit: 3, default: 0
    t.integer "max_swimmer_level", limit: 3, default: 0
    t.index ["title"], name: "index_trainings_on_title", unique: true
  end

  create_table "user_achievements", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
  end

  create_table "user_laps", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "user_result_id", null: false
    t.integer "swimmer_id", null: false
    t.decimal "reaction_time", precision: 5, scale: 2
    t.integer "minutes", limit: 3
    t.integer "seconds", limit: 2
    t.integer "hundredths", limit: 2
    t.integer "length_in_meters"
    t.integer "position", limit: 3
    t.integer "minutes_from_start", limit: 3
    t.integer "seconds_from_start", limit: 2
    t.integer "hundredths_from_start", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["swimmer_id"], name: "index_user_laps_on_swimmer_id"
    t.index ["user_result_id"], name: "index_user_laps_on_user_result_id"
  end

  create_table "user_results", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.decimal "standard_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_points", precision: 10, scale: 2, default: "0.0"
    t.bigint "rank", default: 0
    t.boolean "disqualified", default: false
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundredths", limit: 2, default: 0
    t.integer "swimmer_id"
    t.integer "category_type_id"
    t.integer "pool_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "disqualification_code_type_id"
    t.string "description", limit: 60, default: ""
    t.date "event_date"
    t.decimal "reaction_time", precision: 10, scale: 2, default: "0.0"
    t.integer "event_type_id"
    t.bigint "user_workshop_id", null: false
    t.bigint "swimming_pool_id"
    t.bigint "standard_timing_id"
    t.index ["category_type_id"], name: "fk_user_results_category_types"
    t.index ["disqualification_code_type_id"], name: "idx_user_results_disqualification_code_type"
    t.index ["event_type_id"], name: "fk_user_results_event_types"
    t.index ["pool_type_id"], name: "fk_user_results_pool_types"
    t.index ["standard_timing_id"], name: "index_user_results_on_standard_timing_id"
    t.index ["swimmer_id"], name: "fk_user_results_swimmers"
    t.index ["swimming_pool_id"], name: "index_user_results_on_swimming_pool_id"
    t.index ["user_id"], name: "fk_rails_e406f4db18"
    t.index ["user_workshop_id"], name: "index_user_results_on_user_workshop_id"
  end

  create_table "user_swimmer_confirmations", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "swimmer_id"
    t.integer "user_id"
    t.integer "confirmator_id"
    t.index ["confirmator_id"], name: "index_user_swimmer_confirmations_on_confirmator_id"
    t.index ["user_id", "swimmer_id", "confirmator_id"], name: "user_swimmer_confirmator", unique: true
  end

  create_table "user_training_rows", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "part_order", limit: 3, default: 0
    t.integer "times", limit: 3, default: 0
    t.integer "distance", default: 0
    t.integer "start_and_rest", default: 0
    t.integer "pause", default: 0
    t.integer "group_id", limit: 3, default: 0
    t.integer "group_times", limit: 3, default: 0
    t.integer "group_start_and_rest", default: 0
    t.integer "group_pause", default: 0
    t.integer "user_training_id"
    t.integer "exercise_id"
    t.integer "training_step_type_id"
    t.integer "aux_arms_type_id"
    t.integer "aux_kicks_type_id"
    t.integer "aux_body_type_id"
    t.integer "aux_breath_type_id"
    t.index ["aux_arms_type_id"], name: "idx_user_training_rows_arm_aux_type"
    t.index ["aux_body_type_id"], name: "idx_user_training_rows_body_aux_type"
    t.index ["aux_breath_type_id"], name: "idx_user_training_rows_breath_aux_type"
    t.index ["aux_kicks_type_id"], name: "idx_user_training_rows_kick_aux_type"
    t.index ["exercise_id"], name: "idx_user_training_rows_exercise"
    t.index ["group_id", "part_order"], name: "index_user_training_rows_on_group_id_and_part_order"
    t.index ["training_step_type_id"], name: "idx_user_training_rows_training_step_type"
    t.index ["user_training_id", "part_order"], name: "idx_user_training_rows_part_order"
  end

  create_table "user_training_stories", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "swam_date"
    t.integer "total_training_time", limit: 3, default: 0
    t.text "notes"
    t.integer "user_training_id"
    t.integer "swimming_pool_id"
    t.integer "swimmer_level_type_id"
    t.integer "user_id"
    t.index ["swimmer_level_type_id"], name: "idx_user_training_stories_swimmer_level_type"
    t.index ["swimming_pool_id"], name: "idx_user_training_stories_swimming_pool"
    t.index ["user_id"], name: "idx_user_training_stories_user"
    t.index ["user_training_id", "swam_date"], name: "index_user_training_stories_on_user_training_id_and_swam_date"
  end

  create_table "user_trainings", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description", limit: 250, default: ""
    t.integer "user_id"
    t.index ["user_id", "description"], name: "index_user_trainings_on_user_id_and_description"
  end

  create_table "user_workshops", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.date "header_date"
    t.string "header_year", limit: 10
    t.string "code", limit: 80
    t.string "description", limit: 100
    t.integer "edition"
    t.text "notes"
    t.integer "user_id", null: false
    t.integer "team_id", null: false
    t.integer "season_id", null: false
    t.integer "edition_type_id", default: 3, null: false
    t.integer "timing_type_id", default: 1, null: false
    t.integer "swimming_pool_id"
    t.boolean "autofilled", default: false, null: false
    t.boolean "off_season", default: false, null: false
    t.boolean "confirmed", default: false, null: false
    t.boolean "cancelled", default: false, null: false
    t.boolean "pb_acquired", default: false, null: false
    t.boolean "read_only", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_user_workshops_on_code"
    t.index ["code"], name: "workshop_code", type: :fulltext
    t.index ["description", "code"], name: "workshop_name", type: :fulltext
    t.index ["description"], name: "workshop_desc", type: :fulltext
    t.index ["edition_type_id"], name: "index_user_workshops_on_edition_type_id"
    t.index ["header_date"], name: "index_user_workshops_on_header_date"
    t.index ["header_year"], name: "index_user_workshops_on_header_year"
    t.index ["season_id"], name: "index_user_workshops_on_season_id"
    t.index ["swimming_pool_id"], name: "index_user_workshops_on_swimming_pool_id"
    t.index ["team_id"], name: "index_user_workshops_on_team_id"
    t.index ["timing_type_id"], name: "index_user_workshops_on_timing_type_id"
    t.index ["user_id"], name: "index_user_workshops_on_user_id"
  end

  create_table "users", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "name", limit: 190, null: false
    t.string "description", limit: 100
    t.integer "swimmer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", limit: 190, null: false
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.text "avatar_url"
    t.integer "swimmer_level_type_id"
    t.integer "coach_level_type_id"
    t.string "jwt"
    t.integer "outstanding_goggle_score_bias", default: 800
    t.integer "outstanding_standard_score_bias", default: 800
    t.string "last_name", limit: 50
    t.string "first_name", limit: 50
    t.integer "year_of_birth", default: 1900
    t.string "provider"
    t.string "uid"
    t.boolean "active", default: true, null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["coach_level_type_id"], name: "idx_users_coach_level_type"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jwt"], name: "index_users_on_jwt", unique: true
    t.index ["last_name", "first_name", "year_of_birth"], name: "full_name"
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["swimmer_id"], name: "idx_users_swimmer"
    t.index ["swimmer_level_type_id"], name: "idx_users_swimmer_level_type"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "votes", id: :integer, charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "votable_id"
    t.string "votable_type", collation: "latin1_swedish_ci"
    t.integer "voter_id"
    t.string "voter_type", collation: "latin1_swedish_ci"
    t.boolean "vote_flag"
    t.string "vote_scope", collation: "latin1_swedish_ci"
    t.integer "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_id", "votable_type"], name: "index_votes_on_votable_id_and_votable_type"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
    t.index ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "issues", "users"
  add_foreign_key "laps", "meeting_individual_results"
  add_foreign_key "laps", "swimmers"
  add_foreign_key "laps", "teams"
  add_foreign_key "meeting_event_reservations", "badges"
  add_foreign_key "meeting_event_reservations", "meeting_events"
  add_foreign_key "meeting_event_reservations", "meetings"
  add_foreign_key "meeting_event_reservations", "swimmers"
  add_foreign_key "meeting_event_reservations", "teams"
  add_foreign_key "meeting_relay_reservations", "badges"
  add_foreign_key "meeting_relay_reservations", "meeting_events"
  add_foreign_key "meeting_relay_reservations", "meetings"
  add_foreign_key "meeting_relay_reservations", "swimmers"
  add_foreign_key "meeting_relay_reservations", "teams"
  add_foreign_key "meeting_reservations", "badges"
  add_foreign_key "meeting_reservations", "meetings"
  add_foreign_key "meeting_reservations", "swimmers"
  add_foreign_key "meeting_reservations", "teams"
  add_foreign_key "meeting_reservations", "users"
  add_foreign_key "relay_laps", "meeting_relay_results"
  add_foreign_key "relay_laps", "meeting_relay_swimmers"
  add_foreign_key "relay_laps", "swimmers"
  add_foreign_key "relay_laps", "teams"
  add_foreign_key "swimmer_season_scores", "badges"
  add_foreign_key "swimmer_season_scores", "event_types"
  add_foreign_key "swimmer_season_scores", "meeting_individual_results"
  add_foreign_key "user_laps", "swimmers"
  add_foreign_key "user_laps", "user_results"
  add_foreign_key "user_results", "user_workshops"
  add_foreign_key "user_results", "users"
  add_foreign_key "user_workshops", "edition_types"
  add_foreign_key "user_workshops", "seasons"
  add_foreign_key "user_workshops", "teams"
  add_foreign_key "user_workshops", "timing_types"
  add_foreign_key "user_workshops", "users"

  create_view "last_seasons_ids", sql_definition: <<-SQL
      select `s1`.`id` AS `id` from (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`season_type_id` = 1 order by `seasons`.`begin_date` desc limit 1) `s1` union select `s1_1`.`id` AS `id` from (select `seasons`.`id` AS `id` from (((((`seasons` join `meetings` on(`meetings`.`season_id` = `seasons`.`id`)) join `meeting_sessions` on(`meeting_sessions`.`meeting_id` = `meetings`.`id`)) join `meeting_events` on(`meeting_events`.`meeting_session_id` = `meeting_sessions`.`id`)) join `meeting_programs` on(`meeting_programs`.`meeting_event_id` = `meeting_events`.`id`)) join `meeting_individual_results` on(`meeting_individual_results`.`meeting_program_id` = `meeting_programs`.`id`)) where `seasons`.`season_type_id` = 1 order by `seasons`.`begin_date` desc limit 1) `s1_1` union select `s1_2`.`id` AS `id` from (select `seasons`.`id` AS `id` from (`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) where `seasons`.`season_type_id` = 1 order by `seasons`.`begin_date` desc limit 1) `s1_2` union select `s1_3`.`id` AS `id` from (select `seasons`.`id` AS `id` from ((`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) join `user_results` on(`user_results`.`user_workshop_id` = `user_workshops`.`id`)) where `seasons`.`season_type_id` = 1 order by `seasons`.`begin_date` desc limit 1) `s1_3` union select `s2`.`id` AS `id` from (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`season_type_id` = 7 order by `seasons`.`begin_date` desc limit 1) `s2` union select `s2_1`.`id` AS `id` from (select `seasons`.`id` AS `id` from (((((`seasons` join `meetings` on(`meetings`.`season_id` = `seasons`.`id`)) join `meeting_sessions` on(`meeting_sessions`.`meeting_id` = `meetings`.`id`)) join `meeting_events` on(`meeting_events`.`meeting_session_id` = `meeting_sessions`.`id`)) join `meeting_programs` on(`meeting_programs`.`meeting_event_id` = `meeting_events`.`id`)) join `meeting_individual_results` on(`meeting_individual_results`.`meeting_program_id` = `meeting_programs`.`id`)) where `seasons`.`season_type_id` = 7 order by `seasons`.`begin_date` desc limit 1) `s2_1` union select `s2_2`.`id` AS `id` from (select `seasons`.`id` AS `id` from (`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) where `seasons`.`season_type_id` = 7 order by `seasons`.`begin_date` desc limit 1) `s2_2` union select `s2_3`.`id` AS `id` from (select `seasons`.`id` AS `id` from ((`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) join `user_results` on(`user_results`.`user_workshop_id` = `user_workshops`.`id`)) where `seasons`.`season_type_id` = 7 order by `seasons`.`begin_date` desc limit 1) `s2_3` union select `s3`.`id` AS `id` from (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`season_type_id` = 8 order by `seasons`.`begin_date` desc limit 1) `s3` union select `s3_1`.`id` AS `id` from (select `seasons`.`id` AS `id` from (((((`seasons` join `meetings` on(`meetings`.`season_id` = `seasons`.`id`)) join `meeting_sessions` on(`meeting_sessions`.`meeting_id` = `meetings`.`id`)) join `meeting_events` on(`meeting_events`.`meeting_session_id` = `meeting_sessions`.`id`)) join `meeting_programs` on(`meeting_programs`.`meeting_event_id` = `meeting_events`.`id`)) join `meeting_individual_results` on(`meeting_individual_results`.`meeting_program_id` = `meeting_programs`.`id`)) where `seasons`.`season_type_id` = 8 order by `seasons`.`begin_date` desc limit 1) `s3_1` union select `s2_2`.`id` AS `id` from (select `seasons`.`id` AS `id` from (`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) where `seasons`.`season_type_id` = 8 order by `seasons`.`begin_date` desc limit 1) `s2_2` union select `s2_3`.`id` AS `id` from (select `seasons`.`id` AS `id` from ((`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) join `user_results` on(`user_results`.`user_workshop_id` = `user_workshops`.`id`)) where `seasons`.`season_type_id` = 8 order by `seasons`.`begin_date` desc limit 1) `s2_3`
  SQL
end
