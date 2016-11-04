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

ActiveRecord::Schema.define(version: 20161103111903) do

  create_table "guest_users", force: :cascade do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guest_users", ["user_id"], name: "fk_rails_eb86c8dbd1", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.integer  "status",             limit: 4
    t.string   "content",            limit: 255, null: false
    t.time     "target_time",                    null: false
    t.time     "elapsed_time"
    t.datetime "suspended_at"
    t.datetime "resumed_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "finish_targeted_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree

  create_table "twitter_users", force: :cascade do |t|
    t.string   "uid",        limit: 255, null: false
    t.integer  "user_id",    limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "twitter_users", ["uid"], name: "index_twitter_users_on_uid", using: :btree
  add_index "twitter_users", ["user_id"], name: "fk_rails_64c2b91021", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 255, null: false
    t.string   "image_url",       limit: 255, null: false
    t.boolean  "is_active",                   null: false
    t.string   "remember_digest", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "guest_users", "users"
  add_foreign_key "tasks", "users"
  add_foreign_key "twitter_users", "users"
end
