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

ActiveRecord::Schema.define(version: 20150130203021) do

  create_table "autos", force: :cascade do |t|
    t.text     "maker"
    t.text     "model"
    t.integer  "year"
    t.integer  "price"
    t.text     "town"
    t.integer  "milage"
    t.text     "short_description"
    t.text     "uid"
    t.boolean  "new"
    t.boolean  "active"
    t.datetime "posted_at"
    t.text     "phone"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "makers", force: :cascade do |t|
    t.text    "maker"
    t.text    "autoruname"
    t.integer "autoru"
  end

  create_table "models", force: :cascade do |t|
    t.integer "maker_id"
    t.text    "model"
    t.integer "autoru"
    t.text    "autoruname"
  end

  add_index "models", ["maker_id"], name: "index_models_on_maker_id"

end
