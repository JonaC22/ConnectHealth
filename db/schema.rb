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

ActiveRecord::Schema.define(version: 20150819190143) do

  create_table "annotations", force: true do |t|
    t.integer  "pedigree_id"
    t.integer  "pos_x"
    t.integer  "pos_y"
    t.string   "text"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "annotations", ["pedigree_id"], name: "index_annotations_on_pedigree_id", using: :btree

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

  create_table "medicos", primary_key: "﻿Id_Medico", force: true do |t|
    t.string "Nombre",               limit: 45
    t.string "Apellido",             limit: 45
    t.string "Sexo",                 limit: 45
    t.string "Tipo_Doc",             limit: 45
    t.string "Nro_Doc",              limit: 45
    t.string "Direccion",            limit: 45
    t.string "Telefono",             limit: 45
    t.string "Mail",                 limit: 45
    t.string "Fecha_Nac",            limit: 45
    t.string "Nro_Matricula",        limit: 45
    t.string "Fecha_Atencion_Desde", limit: 45
    t.string "Fecha_Atencion_Hasta", limit: 45
    t.string "Habilitado",           limit: 45
  end

  create_table "pacientes", primary_key: "Nro_Afiliado", force: true do |t|
    t.string "Nombre",               limit: 45
    t.string "Apellido",             limit: 45
    t.string "Sexo",                 limit: 45
    t.string "Tipo_Doc",             limit: 45
    t.string "Nro_Doc",              limit: 45
    t.string "Direccion",            limit: 45
    t.string "Mail",                 limit: 45
    t.string "Telefono",             limit: 45
    t.string "Fecha_Nac",            limit: 45
    t.string "Cod_Plan",             limit: 45
    t.string "Estado_Civil",         limit: 45
    t.string "Nro_Titular",          limit: 45
    t.string "Nro_Conyuge",          limit: 45
    t.string "Fecha_Baja",           limit: 45
    t.string "Nro_Consulta",         limit: 45
    t.string "CantFamiliaresACargo", limit: 45
  end

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

end
