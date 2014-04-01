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

ActiveRecord::Schema.define(version: 20140401035944) do

  create_table "locations", force: true do |t|
    t.text     "searchtext"
    t.text     "address"
    t.integer  "routeid"
    t.integer  "positioninroute"
    t.time     "minduration"
    t.time     "maxduration"
    t.datetime "arrivebefore"
    t.datetime "arriveafter"
    t.datetime "departbefore"
    t.datetime "departafter"
    t.integer  "priority"
    t.boolean  "blacklisted"
    t.boolean  "lockedin"
    t.boolean  "start"
    t.boolean  "dest"
    t.text     "geocode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "routes", force: true do |t|
    t.string   "username"
    t.string   "travelMethod"
    t.string   "routeName"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
