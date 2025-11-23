# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_23_031257) do
  create_table "domain_names", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_domain_names_on_name", unique: true
    t.index ["site_id"], name: "index_domain_names_on_site_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "name", null: false
    t.string "storage_path", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_type", null: false
    t.integer "owner_id", null: false
    t.integer "creator_id", null: false
    t.string "container_id"
    t.index ["creator_id"], name: "index_sites_on_creator_id"
    t.index ["name"], name: "index_sites_on_name", unique: true
    t.index ["owner_type", "owner_id"], name: "index_sites_on_owner"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
  end

  add_foreign_key "domain_names", "sites"
  add_foreign_key "sites", "users", column: "creator_id"
end
