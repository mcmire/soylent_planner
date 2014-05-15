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

ActiveRecord::Schema.define(version: 20140513061626) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "usda_food_groups", id: false, force: true do |t|
    t.string   "code",        null: false
    t.string   "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usda_foods", id: false, force: true do |t|
    t.string   "nutrient_databank_number", null: false
    t.string   "food_group_code"
    t.string   "long_description",         null: false
    t.string   "short_description",        null: false
    t.string   "common_names"
    t.string   "manufacturer_name"
    t.boolean  "survey"
    t.string   "refuse_description"
    t.integer  "percentage_refuse"
    t.string   "scientific_name"
    t.float    "nitrogen_factor"
    t.float    "protein_factor"
    t.float    "fat_factor"
    t.float    "carbohydrate_factor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usda_foods_nutrients", force: true do |t|
    t.string   "nutrient_databank_number",     null: false
    t.string   "nutrient_number",              null: false
    t.float    "nutrient_value",               null: false
    t.integer  "num_data_points",              null: false
    t.float    "standard_error"
    t.string   "src_code",                     null: false
    t.string   "derivation_code"
    t.string   "ref_nutrient_databank_number"
    t.boolean  "add_nutrient_mark"
    t.integer  "num_studies"
    t.float    "min"
    t.float    "max"
    t.integer  "degrees_of_freedom"
    t.float    "lower_error_bound"
    t.float    "upper_error_bound"
    t.string   "statistical_comments"
    t.string   "add_mod_date"
    t.string   "confidence_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "usda_foods_nutrients", ["nutrient_databank_number", "nutrient_number"], name: "foods_nutrients_index", using: :btree

  create_table "usda_footnotes", force: true do |t|
    t.string   "nutrient_databank_number", null: false
    t.string   "footnote_number",          null: false
    t.string   "footnote_type",            null: false
    t.string   "nutrient_number"
    t.string   "footnote_text",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usda_nutrients", id: false, force: true do |t|
    t.string   "nutrient_number",       null: false
    t.string   "units",                 null: false
    t.string   "tagname"
    t.string   "nutrient_description",  null: false
    t.string   "number_decimal_places", null: false
    t.integer  "sort_record_order",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usda_source_codes", force: true do |t|
    t.string   "code",        null: false
    t.string   "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usda_weights", force: true do |t|
    t.string   "nutrient_databank_number", null: false
    t.string   "sequence_number",          null: false
    t.float    "amount",                   null: false
    t.string   "measurement_description",  null: false
    t.float    "gram_weight",              null: false
    t.integer  "num_data_points"
    t.float    "standard_deviation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
