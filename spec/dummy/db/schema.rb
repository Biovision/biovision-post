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

ActiveRecord::Schema.define(version: 20170928000002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "post_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "post_type_id", null: false
    t.integer "parent_id"
    t.integer "priority", limit: 2, default: 1, null: false
    t.integer "posts_count", default: 0, null: false
    t.boolean "locked", default: false, null: false
    t.boolean "visible", default: true, null: false
    t.boolean "deleted", default: false, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "long_slug", null: false
    t.string "parents_cache", default: "", null: false
    t.integer "children_cache", default: [], null: false, array: true
    t.index ["post_type_id"], name: "index_post_categories_on_post_type_id"
  end

  create_table "post_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.integer "posts_count", default: 0, null: false
    t.integer "category_depth", limit: 2, default: 0
    t.string "name", null: false
    t.string "slug", null: false
    t.index ["name"], name: "index_post_types_on_name", unique: true
    t.index ["slug"], name: "index_post_types_on_slug", unique: true
  end

  add_foreign_key "post_categories", "post_categories", column: "parent_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "post_categories", "post_types"
  add_foreign_key "post_types", "post_types", column: "parent_id", on_update: :cascade, on_delete: :cascade
end
