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

ActiveRecord::Schema.define(version: 20140502025750) do

  create_table "blacklist", force: true do |t|
    t.integer  "route_id"
    t.string   "name"
    t.string   "geocode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "routes", force: true do |t|
    t.integer  "user_id"
    t.string   "name",       default: "unnamed_route"
    t.string   "location"
    t.string   "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "routes", ["user_id", "created_at"], name: "index_routes_on_user_id_and_created_at"

  create_table "steps", force: true do |t|
    t.integer  "route_id"
    t.string   "name",       default: "unnamed_location"
    t.string   "geocode"
    t.datetime "arrival"
    t.datetime "departure"
    t.boolean  "lockedin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "steps", ["route_id", "arrival"], name: "index_steps_on_route_id_and_arrival"

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",           default: false
    t.string   "fb_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
