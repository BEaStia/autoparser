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

ActiveRecord::Schema.define(version: 20150405090212) do

  create_table "autos", force: :cascade do |t|
    t.text     "maker",             limit: 65535
    t.text     "model",             limit: 65535
    t.integer  "year",              limit: 4
    t.integer  "price",             limit: 4
    t.text     "town",              limit: 65535
    t.integer  "milage",            limit: 4
    t.text     "short_description", limit: 65535
    t.text     "uid",               limit: 65535
    t.boolean  "new",               limit: 1
    t.boolean  "active",            limit: 1
    t.datetime "posted_at"
    t.text     "phone",             limit: 65535
    t.text     "description",       limit: 65535
    t.text     "color",             limit: 65535
    t.float    "volume",            limit: 24
    t.integer  "hp",                limit: 4
    t.text     "wd",                limit: 65535
    t.text     "fuel",              limit: 65535
    t.text     "body",              limit: 65535
    t.text     "steering_wheel",    limit: 65535
    t.text     "gearbox",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.text     "name",       limit: 65535
    t.text     "password",   limit: 65535
    t.integer  "requests",   limit: 4
    t.integer  "demo",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
