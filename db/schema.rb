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

ActiveRecord::Schema.define(version: 20140922134304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "annotations", force: true do |t|
    t.integer  "image_id"
    t.float    "x_axis"
    t.float    "y_axis"
    t.string   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.integer  "feedback_id"
    t.integer  "user_id"
    t.text     "details"
    t.binary   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "details"
    t.string   "progress_status",             default: "Nil", null: false
    t.string   "abuse_status",                default: "Nil"
    t.string   "delete_status"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "last_acted_at"
    t.datetime "datetime_marked_as_resolved"
    t.integer  "reported_by"
    t.string   "abuse_reason"
    t.integer  "handled_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: true do |t|
    t.integer  "feedback_id"
    t.binary   "image_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.integer  "feedback_id"
    t.integer  "user_id"
    t.integer  "agency_id"
    t.string   "notification_user"
    t.string   "notification_agency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                default: "",        null: false
    t.string   "encrypted_password",   default: "",        null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.string   "nickname"
    t.string   "phone_number"
    t.string   "user_type",            default: "User",    null: false
    t.string   "status",               default: "Created", null: false
    t.string   "verification_code"
    t.datetime "verification_sent_at"
    t.string   "address"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "feedback_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
