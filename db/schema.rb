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

ActiveRecord::Schema.define(version: 20200225165617) do

  create_table "agents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "badge_number"
    t.string   "last_4ssn"
    t.string   "division_unit"
    t.string   "title"
    t.string   "location"
    t.string   "room"
    t.string   "office_phone"
    t.string   "pager_phone"
    t.string   "cell_phone"
    t.string   "supervisor"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "inventories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "item_dec"
    t.string   "serial_num"
    t.string   "status"
    t.date     "status_date"
    t.string   "agent_rec"
    t.string   "incident_rep"
    t.string   "nsn_in_inventory"
    t.text     "notes",            limit: 65535
    t.string   "expendable"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.date     "inc_rep_date"
    t.string   "inc_rep"
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "session_id"
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "status", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "status"
    t.string   "status_description"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "summaries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "item_summary_name"
    t.string   "item_description"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "supervisors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "first_phone"
    t.string   "second_phone"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
