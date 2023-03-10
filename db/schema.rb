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

ActiveRecord::Schema[7.0].define(version: 2023_01_18_204242) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "avails", force: :cascade do |t|
    t.bigint "property_id"
    t.date "first_available"
    t.date "last_available"
    t.index ["property_id"], name: "index_avails_on_property_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "property_id"
    t.date "start_date"
    t.date "end_date"
    t.boolean "approved"
    t.boolean "responded"
    t.index ["property_id"], name: "index_bookings_on_property_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.string "address"
    t.text "description"
    t.integer "daily_rate"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
  end

  add_foreign_key "avails", "properties"
  add_foreign_key "bookings", "properties"
  add_foreign_key "bookings", "users"
  add_foreign_key "properties", "users"
end
