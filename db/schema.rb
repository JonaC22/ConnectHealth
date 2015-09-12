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

ActiveRecord::Schema.define(version: 20150910191808) do

  create_table "annotations", force: true do |t|
    t.integer  "pedigree_id"
    t.integer  "pos_x"
    t.integer  "pos_y"
    t.string   "text"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "annotations", ["pedigree_id"], name: "index_annotations_on_pedigree_id", using: :btree

  create_table "diseases", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "functions", force: true do |t|
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "medical_histories", force: true do |t|
    t.integer  "patient_id"
    t.string   "json_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "medical_histories", ["patient_id"], name: "index_medical_histories_on_patient_id", using: :btree

  create_table "patient_diseases", force: true do |t|
    t.integer  "patient_id"
    t.integer  "disease_id"
    t.integer  "age"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "patient_diseases", ["disease_id"], name: "index_patient_diseases_on_disease_id", using: :btree
  add_index "patient_diseases", ["patient_id"], name: "index_patient_diseases_on_patient_id", using: :btree

  create_table "patients", force: true do |t|
    t.integer  "pedigree_id"
    t.string   "name"
    t.string   "lastname"
    t.string   "document_type"
    t.string   "document_number"
    t.boolean  "active",          default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "gender"
    t.date     "birth_date"
    t.integer  "neo_id"
    t.integer  "status"
  end

  add_index "patients", ["document_number"], name: "index_patients_on_document_number", unique: true, using: :btree
  add_index "patients", ["pedigree_id"], name: "index_patients_on_pedigree_id", using: :btree

  create_table "pedigrees", force: true do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "queries", force: true do |t|
    t.string   "statement"
    t.string   "description"
    t.string   "result"
    t.integer  "user_id"
    t.integer  "pedigree_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "queries", ["pedigree_id"], name: "index_queries_on_pedigree_id", using: :btree
  add_index "queries", ["user_id"], name: "index_queries_on_user_id", using: :btree

  create_table "role_functions", force: true do |t|
    t.integer  "role_id"
    t.integer  "function_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "role_functions", ["function_id"], name: "index_role_functions_on_function_id", using: :btree
  add_index "role_functions", ["role_id"], name: "index_role_functions_on_role_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "description"
    t.boolean  "active"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "statistical_reports", force: true do |t|
    t.integer  "user_id"
    t.string   "statement"
    t.string   "description"
    t.string   "result"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "statistical_reports", ["user_id"], name: "index_statistical_reports_on_user_id", using: :btree

  create_table "user_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "password_digest"
    t.boolean  "active",          default: true
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "widgets", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "stock"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
