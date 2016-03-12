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

ActiveRecord::Schema.define(version: 20160309164258) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.string   "team_name"
    t.string   "team_city"
    t.string   "division"
    t.string   "league"
    t.integer  "year"
    t.float    "avg"
    t.integer  "home_runs"
    t.integer  "rbi"
    t.integer  "runs"
    t.string   "stolen_bases"
    t.string   "int"
    t.float    "ops"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
