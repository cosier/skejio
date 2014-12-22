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

ActiveRecord::Schema.define(version: 20141223193733) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "appointment_selection_states", force: true do |t|
    t.integer  "scheduler_session_id",                 null: false
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "meta"
    t.integer  "device_type"
    t.boolean  "is_finished",          default: false
    t.string   "uuid"
  end

  add_index "appointment_selection_states", ["uuid"], name: "index_appointment_selection_states_on_uuid", using: :btree

  create_table "appointment_selection_transitions", force: true do |t|
    t.string   "to_state",                                      null: false
    t.text     "metadata",                       default: "{}"
    t.integer  "sort_key",                                      null: false
    t.integer  "appointment_selection_state_id",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appointments", force: true do |t|
    t.integer  "business_id",                           null: false
    t.integer  "service_provider_id",                   null: false
    t.integer  "office_id",                             null: false
    t.integer  "customer_id",                           null: false
    t.integer  "created_by_session_id",                 null: false
    t.datetime "start"
    t.datetime "end"
    t.text     "organizer"
    t.text     "description"
    t.text     "summary"
    t.text     "attendees"
    t.text     "location"
    t.integer  "status"
    t.text     "notes"
    t.boolean  "is_confirmed",          default: false
    t.boolean  "is_active",             default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "service_id",                            null: false
  end

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

  create_table "customers", force: true do |t|
    t.string   "phone_number"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "sms_verified",       default: false
    t.boolean  "voice_verified",     default: false
    t.string   "verification_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recording_name_url"
  end

  create_table "facts", force: true do |t|
    t.integer  "system_log_id"
    t.string   "title"
    t.integer  "type"
    t.text     "payload"
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
    t.integer  "sort_order"
  end

  add_index "offices", ["business_id", "id"], name: "business_office", using: :btree

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

  create_table "scheduler_session_transitions", force: true do |t|
    t.string   "to_state",                            null: false
    t.text     "metadata",             default: "{}"
    t.integer  "sort_key",                            null: false
    t.integer  "scheduler_session_id",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scheduler_sessions", force: true do |t|
    t.integer  "business_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "meta"
    t.integer  "device_type"
    t.boolean  "is_finished", default: false
    t.string   "uuid"
  end

  add_index "scheduler_sessions", ["uuid"], name: "index_scheduler_sessions_on_uuid", using: :btree

  create_table "services", force: true do |t|
    t.integer  "business_id",                null: false
    t.string   "name",                       null: false
    t.text     "description"
    t.integer  "duration",    default: 60
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",   default: true
    t.integer  "sort_order"
  end

  add_index "services", ["business_id", "id"], name: "business_service", using: :btree

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

  add_index "settings", ["business_id", "id"], name: "business_setting", using: :btree

  create_table "sub_accounts", force: true do |t|
    t.integer  "business_id"
    t.string   "friendly_name"
    t.string   "auth_token"
    t.string   "sid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_logs", force: true do |t|
    t.integer  "parent_id"
    t.integer  "business_id"
    t.integer  "customer_id"
    t.integer  "session_id"
    t.integer  "session_tx_id"
    t.integer  "log_type"
    t.string   "from"
    t.string   "to"
    t.text     "meta"
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

  add_index "users", ["business_id", "id"], name: "business_user", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
