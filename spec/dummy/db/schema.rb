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

ActiveRecord::Schema.define(version: 20170930000003) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "browser_id"
    t.boolean "bot", default: false, null: false
    t.boolean "mobile", default: false, null: false
    t.boolean "active", default: true, null: false
    t.boolean "locked", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.string "name", null: false
    t.index ["browser_id"], name: "index_agents_on_browser_id"
    t.index ["name"], name: "index_agents_on_name"
  end

  create_table "browsers", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bot", default: false, null: false
    t.boolean "mobile", default: false, null: false
    t.boolean "active", default: true, null: false
    t.boolean "locked", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.integer "agents_count", default: 0, null: false
    t.string "name", null: false
    t.index ["name"], name: "index_browsers_on_name"
  end

  create_table "code_types", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
  end

  create_table "codes", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "code_type_id", null: false
    t.integer "user_id"
    t.integer "agent_id"
    t.inet "ip"
    t.integer "quantity", limit: 2, default: 1, null: false
    t.string "body", null: false
    t.string "payload"
    t.index ["agent_id"], name: "index_codes_on_agent_id"
    t.index ["body", "code_type_id", "quantity"], name: "index_codes_on_body_and_code_type_id_and_quantity"
    t.index ["code_type_id"], name: "index_codes_on_code_type_id"
    t.index ["user_id"], name: "index_codes_on_user_id"
  end

  create_table "editable_pages", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.string "name", null: false
    t.string "image"
    t.string "title", default: "", null: false
    t.string "keywords", default: "", null: false
    t.string "description", default: "", null: false
    t.text "body", default: "", null: false
  end

  create_table "foreign_sites", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.string "name", null: false
    t.integer "foreign_users_count", default: 0, null: false
  end

  create_table "foreign_users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "foreign_site_id", null: false
    t.integer "user_id", null: false
    t.integer "agent_id"
    t.inet "ip"
    t.string "slug", null: false
    t.string "email"
    t.string "name"
    t.text "data"
    t.index ["agent_id"], name: "index_foreign_users_on_agent_id"
    t.index ["foreign_site_id"], name: "index_foreign_users_on_foreign_site_id"
    t.index ["user_id"], name: "index_foreign_users_on_user_id"
  end

  create_table "login_attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "agent_id"
    t.inet "ip"
    t.string "password", default: "", null: false
    t.index ["agent_id"], name: "index_login_attempts_on_agent_id"
    t.index ["user_id"], name: "index_login_attempts_on_user_id"
  end

  create_table "metric_values", id: :serial, force: :cascade do |t|
    t.integer "metric_id", null: false
    t.datetime "time", null: false
    t.integer "quantity", default: 1, null: false
    t.index "date_trunc('day'::text, \"time\")", name: "metric_values_day_idx"
    t.index ["metric_id"], name: "index_metric_values_on_metric_id"
  end

  create_table "metrics", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "incremental", default: false, null: false
    t.boolean "start_with_zero", default: false, null: false
    t.boolean "show_on_dashboard", default: true, null: false
    t.integer "default_period", limit: 2, default: 7, null: false
    t.integer "value", default: 0, null: false
    t.integer "previous_value", default: 0, null: false
    t.string "name", null: false
    t.string "description", default: "", null: false
  end

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

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "post_type_id", null: false
    t.bigint "post_category_id", null: false
    t.bigint "region_id"
    t.bigint "agent_id"
    t.inet "ip"
    t.datetime "publication_time"
    t.boolean "visible", default: true, null: false
    t.boolean "locked", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.boolean "approved", default: true, null: false
    t.boolean "show_owner", default: true, null: false
    t.boolean "allow_comments", default: true, null: false
    t.integer "privacy", limit: 2, default: 0
    t.integer "original_post_id"
    t.integer "comments_count", default: 0, null: false
    t.integer "view_count", default: 0, null: false
    t.integer "upvote_count", default: 0, null: false
    t.integer "downvote_count", default: 0, null: false
    t.integer "vote_result", default: 0, null: false
    t.string "uuid", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.string "video_url"
    t.string "image"
    t.string "image_name"
    t.string "image_author_name"
    t.string "image_author_link"
    t.string "source_name"
    t.string "source_link"
    t.text "lead"
    t.text "body", null: false
    t.string "tags_cache", default: [], null: false, array: true
    t.index "date_trunc('month'::text, publication_time), post_type_id, user_id", name: "posts_published_month_idx"
    t.index ["agent_id"], name: "index_posts_on_agent_id"
    t.index ["post_category_id"], name: "index_posts_on_post_category_id"
    t.index ["post_type_id"], name: "index_posts_on_post_type_id"
    t.index ["region_id"], name: "index_posts_on_region_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "privilege_group_privileges", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "privilege_group_id", null: false
    t.integer "privilege_id", null: false
    t.index ["privilege_group_id"], name: "index_privilege_group_privileges_on_privilege_group_id"
    t.index ["privilege_id"], name: "index_privilege_group_privileges_on_privilege_id"
  end

  create_table "privilege_groups", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description", default: "", null: false
    t.index ["slug"], name: "index_privilege_groups_on_slug", unique: true
  end

  create_table "privileges", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.boolean "locked", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.boolean "regional", default: false, null: false
    t.integer "priority", limit: 2, default: 1, null: false
    t.integer "users_count", default: 0, null: false
    t.string "parents_cache", default: "", null: false
    t.integer "children_cache", default: [], null: false, array: true
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description", default: "", null: false
    t.index ["slug"], name: "index_privileges_on_slug", unique: true
  end

  create_table "regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.integer "users_count", default: 0, null: false
    t.boolean "visible", default: true, null: false
    t.boolean "locked", default: false, null: false
    t.float "latitude"
    t.float "longitude"
    t.string "slug", null: false
    t.string "long_slug", null: false
    t.string "name", null: false
    t.string "short_name"
    t.string "locative"
    t.string "image"
    t.string "header_image"
    t.string "parents_cache", default: "", null: false
    t.integer "children_cache", default: [], null: false, array: true
  end

  create_table "stored_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.string "value"
    t.string "name"
    t.string "description"
  end

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "agent_id"
    t.inet "ip"
    t.datetime "last_used"
    t.boolean "active", default: true, null: false
    t.string "token"
    t.index ["agent_id"], name: "index_tokens_on_agent_id"
    t.index ["last_used"], name: "index_tokens_on_last_used"
    t.index ["token"], name: "index_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "user_privileges", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "region_id"
    t.integer "user_id", null: false
    t.integer "privilege_id", null: false
    t.index ["privilege_id"], name: "index_user_privileges_on_privilege_id"
    t.index ["region_id"], name: "index_user_privileges_on_region_id"
    t.index ["user_id"], name: "index_user_privileges_on_user_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "gender", limit: 2
    t.date "birthday"
    t.string "name"
    t.string "patronymic"
    t.string "surname"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "region_id"
    t.integer "agent_id"
    t.inet "ip"
    t.integer "inviter_id"
    t.integer "native_id"
    t.integer "follower_count", default: 0, null: false
    t.integer "followee_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "authority", default: 0, null: false
    t.integer "upvote_count", default: 0, null: false
    t.integer "downvote_count", default: 0, null: false
    t.integer "vote_result", default: 0, null: false
    t.boolean "super_user", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.boolean "bot", default: false, null: false
    t.boolean "allow_login", default: true, null: false
    t.boolean "email_confirmed", default: false, null: false
    t.boolean "phone_confirmed", default: false, null: false
    t.boolean "allow_mail", default: true, null: false
    t.boolean "foreign_slug", default: false, null: false
    t.datetime "last_seen"
    t.string "slug", null: false
    t.string "screen_name", null: false
    t.string "password_digest"
    t.string "email"
    t.string "phone"
    t.string "image"
    t.string "notice"
    t.string "search_string"
    t.index ["agent_id"], name: "index_users_on_agent_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["region_id"], name: "index_users_on_region_id"
    t.index ["screen_name"], name: "index_users_on_screen_name"
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "agents", "browsers"
  add_foreign_key "codes", "agents"
  add_foreign_key "codes", "code_types"
  add_foreign_key "codes", "users"
  add_foreign_key "foreign_users", "agents"
  add_foreign_key "foreign_users", "foreign_sites"
  add_foreign_key "foreign_users", "users"
  add_foreign_key "login_attempts", "agents"
  add_foreign_key "login_attempts", "users"
  add_foreign_key "metric_values", "metrics"
  add_foreign_key "post_categories", "post_categories", column: "parent_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "post_categories", "post_types"
  add_foreign_key "post_types", "post_types", column: "parent_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "posts", "agents"
  add_foreign_key "posts", "post_categories"
  add_foreign_key "posts", "post_types"
  add_foreign_key "posts", "regions"
  add_foreign_key "posts", "users"
  add_foreign_key "privilege_group_privileges", "privilege_groups"
  add_foreign_key "privilege_group_privileges", "privileges"
  add_foreign_key "privileges", "privileges", column: "parent_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "regions", "regions", column: "parent_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tokens", "agents"
  add_foreign_key "tokens", "users"
  add_foreign_key "user_privileges", "privileges"
  add_foreign_key "user_privileges", "regions"
  add_foreign_key "user_privileges", "users"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "users", "agents"
  add_foreign_key "users", "regions"
  add_foreign_key "users", "users", column: "inviter_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "users", "users", column: "native_id", on_update: :cascade, on_delete: :nullify
end
