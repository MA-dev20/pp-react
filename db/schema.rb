# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_08_121943) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "catchword_list_catchwords", force: :cascade do |t|
    t.bigint "catchword_list_id"
    t.bigint "catchword_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catchword_id"], name: "index_catchword_list_catchwords_on_catchword_id"
    t.index ["catchword_list_id"], name: "index_catchword_list_catchwords_on_catchword_list_id"
  end

  create_table "catchword_lists", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "user_id"
    t.bigint "game_id"
    t.string "name"
    t.integer "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_catchword_lists_on_company_id"
    t.index ["game_id"], name: "index_catchword_lists_on_game_id"
    t.index ["user_id"], name: "index_catchword_lists_on_user_id"
  end

  create_table "catchwords", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.string "sound"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_catchwords_on_company_id"
  end

  create_table "coaches", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_coaches_on_company_id"
    t.index ["user_id"], name: "index_coaches_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "game_turn_id"
    t.bigint "user_id"
    t.integer "time", default: 0
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "positive"
    t.index ["game_turn_id"], name: "index_comments_on_game_turn_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "logo"
    t.boolean "activated", default: false
    t.integer "employees"
    t.string "message"
    t.integer "color1", default: [69, 177, 255], array: true
    t.integer "color2", default: [29, 218, 175], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_departments_on_company_id"
  end

  create_table "do_and_donts", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "department_id"
    t.bigint "user_id"
    t.string "does"
    t.string "donts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_do_and_donts_on_company_id"
    t.index ["department_id"], name: "index_do_and_donts_on_department_id"
    t.index ["user_id"], name: "index_do_and_donts_on_user_id"
  end

  create_table "game_ratings", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "team_id"
    t.bigint "rating_criterium_id"
    t.integer "rating", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_ratings_on_game_id"
    t.index ["rating_criterium_id"], name: "index_game_ratings_on_rating_criterium_id"
    t.index ["team_id"], name: "index_game_ratings_on_team_id"
  end

  create_table "game_turn_ratings", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "game_turn_id"
    t.bigint "user_id"
    t.bigint "rating_criterium_id"
    t.integer "rating", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_turn_ratings_on_game_id"
    t.index ["game_turn_id"], name: "index_game_turn_ratings_on_game_turn_id"
    t.index ["rating_criterium_id"], name: "index_game_turn_ratings_on_rating_criterium_id"
    t.index ["user_id"], name: "index_game_turn_ratings_on_user_id"
  end

  create_table "game_turns", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "user_id"
    t.bigint "team_id"
    t.bigint "catchword_id"
    t.integer "counter", default: 0
    t.boolean "choosen", default: false
    t.boolean "play", default: true
    t.boolean "played", default: false
    t.integer "place"
    t.boolean "record_pitch", default: false
    t.integer "ges_rating", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "repeat", default: false
    t.bigint "task_id"
    t.index ["catchword_id"], name: "index_game_turns_on_catchword_id"
    t.index ["game_id"], name: "index_game_turns_on_game_id"
    t.index ["task_id"], name: "index_game_turns_on_task_id"
    t.index ["team_id"], name: "index_game_turns_on_team_id"
    t.index ["user_id"], name: "index_game_turns_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "user_id"
    t.bigint "team_id"
    t.string "state"
    t.string "password"
    t.boolean "active", default: true
    t.integer "current_turn"
    t.integer "turn1"
    t.integer "turn2"
    t.boolean "rate", default: true
    t.integer "ges_rating"
    t.integer "game_seconds"
    t.integer "video_id"
    t.string "youtube_url"
    t.boolean "video_is_pitch"
    t.boolean "video_uploading"
    t.boolean "video_toggle"
    t.boolean "video_upload_start"
    t.boolean "replay", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "rating_list_id"
    t.boolean "skip_elections", default: false
    t.integer "max_users", default: 0
    t.string "show_ratings", default: "all"
    t.integer "rating_user"
    t.boolean "skip_rating_timer", default: false
    t.bigint "pitch_id"
    t.index ["company_id"], name: "index_games_on_company_id"
    t.index ["pitch_id"], name: "index_games_on_pitch_id"
    t.index ["rating_list_id"], name: "index_games_on_rating_list_id"
    t.index ["team_id"], name: "index_games_on_team_id"
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "histories", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "department_id"
    t.bigint "user_id"
    t.integer "users"
    t.string "history"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_histories_on_company_id"
    t.index ["department_id"], name: "index_histories_on_department_id"
    t.index ["user_id"], name: "index_histories_on_user_id"
  end

  create_table "objection_list_objections", force: :cascade do |t|
    t.bigint "objection_list_id"
    t.bigint "objection_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["objection_id"], name: "index_objection_list_objections_on_objection_id"
    t.index ["objection_list_id"], name: "index_objection_list_objections_on_objection_list_id"
  end

  create_table "objection_lists", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "user_id"
    t.bigint "game_id"
    t.string "name"
    t.integer "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_objection_lists_on_company_id"
    t.index ["game_id"], name: "index_objection_lists_on_game_id"
    t.index ["user_id"], name: "index_objection_lists_on_user_id"
  end

  create_table "objections", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.string "sound"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_objections_on_company_id"
  end

  create_table "pitch_videos", force: :cascade do |t|
    t.bigint "game_turn_id"
    t.bigint "user_id"
    t.string "video"
    t.integer "duration"
    t.boolean "favorite", default: false
    t.boolean "released", default: false
    t.string "video_text"
    t.integer "words_count", default: 0
    t.integer "do_words", default: 0
    t.integer "dont_words", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_turn_id"], name: "index_pitch_videos_on_game_turn_id"
    t.index ["user_id"], name: "index_pitch_videos_on_user_id"
  end

  create_table "pitches", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "pitch_sound", default: true
    t.string "show_ratings", default: "all"
    t.text "video_path"
    t.boolean "skip_elections", default: false
    t.string "video"
    t.string "image"
    t.boolean "destroy_video", default: false
    t.boolean "destroy_image", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pitches_on_user_id"
  end

  create_table "rating_criteria", force: :cascade do |t|
    t.string "name"
    t.string "icon", default: "fa-star"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rating_list_rating_criteria", force: :cascade do |t|
    t.bigint "rating_list_id"
    t.bigint "rating_criterium_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rating_criterium_id"], name: "index_rating_list_rating_criteria_on_rating_criterium_id"
    t.index ["rating_list_id"], name: "index_rating_list_rating_criteria_on_rating_list_id"
  end

  create_table "rating_lists", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "user_id"
    t.string "name"
    t.integer "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_rating_lists_on_company_id"
    t.index ["user_id"], name: "index_rating_lists_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "game_turn_id"
    t.bigint "user_id"
    t.bigint "rating_criterium_id"
    t.integer "rating", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_turn_id"], name: "index_ratings_on_game_turn_id"
    t.index ["rating_criterium_id"], name: "index_ratings_on_rating_criterium_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "task_media", force: :cascade do |t|
    t.string "audio"
    t.string "video"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.string "thumbnail"
    t.integer "time"
    t.string "type"
    t.string "catchwords"
    t.string "catchword_ids"
    t.string "image"
    t.string "video"
    t.string "audio"
    t.string "reactions"
    t.string "reaction_ids"
    t.string "ratings"
    t.string "video_id"
    t.string "audio_id"
    t.string "media_option", default: "catchword"
    t.string "destroy_media"
    t.bigint "user_id"
    t.bigint "pitch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pitch_id"], name: "index_tasks_on_pitch_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "team_ratings", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "rating_criterium_id"
    t.integer "rating", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rating_criterium_id"], name: "index_team_ratings_on_rating_criterium_id"
    t.index ["team_id"], name: "index_team_ratings_on_team_id"
  end

  create_table "team_users", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_users_on_team_id"
    t.index ["user_id"], name: "index_team_users_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "department_id"
    t.bigint "user_id"
    t.string "name"
    t.string "logo"
    t.integer "ges_rating", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_teams_on_company_id"
    t.index ["department_id"], name: "index_teams_on_department_id"
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "user_ratings", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "rating_criterium_id"
    t.integer "rating", default: 0
    t.integer "change", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rating_criterium_id"], name: "index_user_ratings_on_rating_criterium_id"
    t.index ["user_id"], name: "index_user_ratings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "department_id"
    t.string "fname"
    t.string "lname"
    t.string "avatar"
    t.string "street"
    t.string "city"
    t.string "phone"
    t.string "position"
    t.string "bo_role", default: "none"
    t.boolean "coach", default: false
    t.string "role", default: "user"
    t.integer "zipcode"
    t.integer "ges_rating", default: 0
    t.integer "ges_change", default: 0
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.bigint "department_id"
    t.string "video"
    t.integer "duration"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_videos_on_company_id"
    t.index ["department_id"], name: "index_videos_on_department_id"
    t.index ["user_id"], name: "index_videos_on_user_id"
  end

  add_foreign_key "catchword_list_catchwords", "catchword_lists"
  add_foreign_key "catchword_list_catchwords", "catchwords"
  add_foreign_key "catchword_lists", "companies"
  add_foreign_key "catchword_lists", "games"
  add_foreign_key "catchword_lists", "users"
  add_foreign_key "catchwords", "companies"
  add_foreign_key "coaches", "companies"
  add_foreign_key "coaches", "users"
  add_foreign_key "comments", "game_turns"
  add_foreign_key "comments", "users"
  add_foreign_key "departments", "companies"
  add_foreign_key "do_and_donts", "companies"
  add_foreign_key "do_and_donts", "departments"
  add_foreign_key "do_and_donts", "users"
  add_foreign_key "game_ratings", "games"
  add_foreign_key "game_ratings", "rating_criteria"
  add_foreign_key "game_ratings", "teams"
  add_foreign_key "game_turn_ratings", "game_turns"
  add_foreign_key "game_turn_ratings", "games"
  add_foreign_key "game_turn_ratings", "rating_criteria"
  add_foreign_key "game_turn_ratings", "users"
  add_foreign_key "game_turns", "catchwords"
  add_foreign_key "game_turns", "games"
  add_foreign_key "game_turns", "tasks"
  add_foreign_key "game_turns", "users"
  add_foreign_key "games", "companies"
  add_foreign_key "games", "pitches"
  add_foreign_key "games", "rating_lists"
  add_foreign_key "games", "teams"
  add_foreign_key "games", "users"
  add_foreign_key "histories", "companies"
  add_foreign_key "histories", "departments"
  add_foreign_key "histories", "users"
  add_foreign_key "objection_list_objections", "objection_lists"
  add_foreign_key "objection_list_objections", "objections"
  add_foreign_key "objection_lists", "companies"
  add_foreign_key "objection_lists", "games"
  add_foreign_key "objection_lists", "users"
  add_foreign_key "objections", "companies"
  add_foreign_key "pitch_videos", "game_turns"
  add_foreign_key "pitch_videos", "users"
  add_foreign_key "pitches", "users"
  add_foreign_key "rating_list_rating_criteria", "rating_criteria"
  add_foreign_key "rating_list_rating_criteria", "rating_lists"
  add_foreign_key "rating_lists", "companies"
  add_foreign_key "rating_lists", "users"
  add_foreign_key "ratings", "game_turns"
  add_foreign_key "ratings", "rating_criteria"
  add_foreign_key "ratings", "users"
  add_foreign_key "tasks", "pitches"
  add_foreign_key "tasks", "users"
  add_foreign_key "team_ratings", "rating_criteria"
  add_foreign_key "team_ratings", "teams"
  add_foreign_key "team_users", "teams"
  add_foreign_key "team_users", "users"
  add_foreign_key "teams", "companies"
  add_foreign_key "teams", "departments"
  add_foreign_key "teams", "users"
  add_foreign_key "user_ratings", "rating_criteria"
  add_foreign_key "user_ratings", "users"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "departments"
  add_foreign_key "videos", "companies"
  add_foreign_key "videos", "departments"
  add_foreign_key "videos", "users"
end
