# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141122232941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "break_offices", force: true do |t|
    t.integer  "break_shift_id"
    t.integer  "office_id"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "break_services", force: true do |t|
    t.integer  "break_shift_id"
    t.integer  "service_id"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "break_shifts", force: true do |t|
    t.integer  "business_id",                     null: false
    t.integer  "office_id"
    t.integer  "schedule_rule_id",                null: false
    t.integer  "day",                             null: false
    t.integer  "start_hour",                      null: false
    t.integer  "start_minute",                    null: false
    t.integer  "end_hour",                        null: false
    t.integer  "end_minute",                      null: false
    t.boolean  "is_enabled",       default: true
    t.datetime "valid_from_at"
    t.datetime "valid_until_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "floating_break",   default: 0
  end

  create_table "businesses", force: true do |t|
    t.string   "name",                           null: false
    t.string   "slug",                           null: false
    t.text     "description"
    t.string   "billing_name"
    t.string   "billing_phone"
    t.string   "billing_email"
    t.text     "billing_address"
    t.boolean  "is_listed",       default: true
    t.boolean  "is_active",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "numbers", force: true do |t|
    t.integer  "sub_account_id"
    t.integer  "office_id"
    t.string   "phone_number",       null: false
    t.string   "sid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sms_url"
    t.string   "voice_url"
    t.string   "status_url"
    t.string   "voice_fallback_url"
    t.string   "sms_fallback_url"
    t.string   "friendly_name"
    t.integer  "capabilities"
    t.string   "account_sid"
    t.string   "voice_method"
    t.string   "sms_method"
  end

  add_index "numbers", ["office_id"], name: "index_numbers_on_office_id", using: :btree
  add_index "numbers", ["sub_account_id"], name: "index_numbers_on_sub_account_id", using: :btree

  create_table "offices", force: true do |t|
    t.integer  "business_id",                       null: false
    t.string   "name"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_schedule_public", default: true
    t.string   "time_zone"
  end

  create_table "phones", force: true do |t|
    t.string   "subaccount"
    t.string   "number"
    t.integer  "phonable_id"
    t.string   "phonable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sid"
    t.string   "sauth_token"
  end

  add_index "phones", ["phonable_id", "phonable_type"], name: "index_phones_on_phonable_id_and_phonable_type", using: :btree

  create_table "schedule_rules", force: true do |t|
    t.integer  "service_provider_id",                null: false
    t.integer  "business_id",                        null: false
    t.boolean  "is_active",           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", force: true do |t|
    t.integer  "business_id",                null: false
    t.string   "name",                       null: false
    t.text     "description"
    t.integer  "priority",    default: 1
    t.integer  "duration",    default: 60
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",   default: true
  end

  create_table "settings", force: true do |t|
    t.integer  "business_id",                     null: false
    t.string   "key",                             null: false
    t.string   "value",                           null: false
    t.text     "description"
    t.boolean  "is_active",        default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supportable_id"
    t.string   "supportable_type"
  end

  create_table "sub_accounts", force: true do |t|
    t.integer  "business_id"
    t.string   "friendly_name"
    t.string   "auth_token"
    t.string   "sid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_entries", force: true do |t|
    t.integer  "business_id",                   null: false
    t.integer  "office_id"
    t.integer  "time_sheet_id",                 null: false
    t.integer  "day",                           null: false
    t.integer  "start_hour",                    null: false
    t.integer  "start_minute",                  null: false
    t.integer  "end_hour",                      null: false
    t.integer  "end_minute",                    null: false
    t.boolean  "is_enabled",     default: true
    t.datetime "valid_from_at"
    t.datetime "valid_until_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_sheet_services", force: true do |t|
    t.integer  "business_id"
    t.integer  "service_id"
    t.integer  "time_sheet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_sheets", force: true do |t|
    t.integer  "business_id",      null: false
    t.integer  "schedule_rule_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_from_at"
    t.datetime "valid_until_at"
  end

  create_table "users", force: true do |t|
    t.integer  "business_id"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "roles"
    t.integer  "status"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.integer  "sort_order",             default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
