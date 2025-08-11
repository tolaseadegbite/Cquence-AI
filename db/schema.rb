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

ActiveRecord::Schema[8.0].define(version: 2025_08_11_004210) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "song_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_likes_on_song_id"
    t.index ["user_id", "song_id"], name: "index_likes_on_user_id_and_song_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "recovery_codes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "code", null: false
    t.boolean "used", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recovery_codes_on_user_id"
  end

  create_table "security_keys", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "external_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_security_keys_on_external_id", unique: true
    t.index ["user_id"], name: "index_security_keys_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "sudo_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sign_in_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sign_in_tokens_on_user_id"
  end

  create_table "song_categories", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_song_categories_on_category_id"
    t.index ["song_id"], name: "index_song_categories_on_song_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "title"
    t.string "s3_key"
    t.string "thumbnail_s3_key"
    t.integer "status", default: 0
    t.boolean "instrumental", default: false
    t.text "prompt"
    t.text "lyrics"
    t.text "full_described_song"
    t.text "described_lyrics"
    t.float "guidance_scale"
    t.float "infer_step"
    t.float "audio_duration"
    t.float "seed"
    t.boolean "published", default: false
    t.integer "listen_count", default: 0
    t.integer "likes_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_songs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.bigint "credits", default: 100, null: false
    t.boolean "verified", default: false, null: false
    t.boolean "otp_required_for_sign_in", default: false, null: false
    t.string "otp_secret", null: false
    t.string "webauthn_id", null: false
    t.string "provider"
    t.string "uid"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "songs_count", default: 0
    t.integer "likes_count", default: 0
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "events", "users"
  add_foreign_key "likes", "songs"
  add_foreign_key "likes", "users"
  add_foreign_key "recovery_codes", "users"
  add_foreign_key "security_keys", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "sign_in_tokens", "users"
  add_foreign_key "song_categories", "categories"
  add_foreign_key "song_categories", "songs"
  add_foreign_key "songs", "users"
  add_foreign_key "users", "accounts"
end
