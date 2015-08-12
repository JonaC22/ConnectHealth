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

ActiveRecord::Schema.define(version: 20150809232516) do

  create_table "annotations", force: true do |t|
    t.integer "id_pedigree", limit: 8,    null: false
    t.string  "pos_x",       limit: 45,   null: false
    t.string  "pos_y",       limit: 45,   null: false
    t.string  "text",        limit: 1000, null: false
  end

  add_index "annotations", ["id_pedigree"], name: "fk_annotations_pedigree_idx", using: :btree

  create_table "functions", force: true do |t|
    t.string "description", limit: 45, null: false
  end

  create_table "medical_histories", force: true do |t|
    t.integer  "patient_id"
    t.string   "json_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "medical_histories", ["patient_id"], name: "index_medical_histories_on_patient_id", using: :btree

  create_table "medical_history", force: true do |t|
    t.integer "id_patient", limit: 8,     null: false
    t.string  "json_text",  limit: 10000, null: false
  end

  add_index "medical_history", ["id_patient"], name: "fk_medical_history_patient_idx", using: :btree

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
    t.string  "name",            limit: 45, null: false
    t.string  "lastname",        limit: 45, null: false
    t.string  "document_type",   limit: 10, null: false
    t.integer "document_number", limit: 8,  null: false
    t.integer "active",          limit: 1,  null: false
    t.integer "pedigree_id"
  end

  add_index "patients", ["pedigree_id"], name: "index_patients_on_pedigree_id", using: :btree

  create_table "pedigrees", force: true do |t|
    t.integer "id_patient",  limit: 8, null: false
    t.date    "create_date",           null: false
  end

  add_index "pedigrees", ["id_patient"], name: "fk_pedigrees_patient_idx", using: :btree

  create_table "queries", force: true do |t|
    t.date    "create_date",              null: false
    t.string  "query",       limit: 1000, null: false
    t.string  "description", limit: 45,   null: false
    t.string  "result",      limit: 1000, null: false
    t.integer "made_by",     limit: 8,    null: false
    t.integer "id_pedigree", limit: 8,    null: false
  end

  add_index "queries", ["id_pedigree"], name: "fk_queries_pedigree_idx", using: :btree
  add_index "queries", ["made_by"], name: "fk_queries_user_idx", using: :btree

  create_table "role_functions", id: false, force: true do |t|
    t.integer "id_role",     limit: 8, null: false
    t.integer "id_function", limit: 8, null: false
  end

  add_index "role_functions", ["id_function"], name: "fk_role_functions_function_idx", using: :btree

  create_table "roles", force: true do |t|
    t.string  "description", limit: 45, null: false
    t.integer "active",      limit: 1,  null: false
  end

  create_table "statistical_reports", force: true do |t|
    t.date    "create_date",              null: false
    t.string  "query",       limit: 1000, null: false
    t.string  "description", limit: 45,   null: false
    t.string  "result",      limit: 1000, null: false
    t.integer "made_by",     limit: 8,    null: false
  end

  add_index "statistical_reports", ["made_by"], name: "fk_statistical_reports_idx", using: :btree

  create_table "user_roles", id: false, force: true do |t|
    t.integer "id_user", limit: 8, null: false
    t.integer "id_role", limit: 8, null: false
  end

  add_index "user_roles", ["id_role"], name: "fk_user_roles_role_idx", using: :btree

  create_table "users", force: true do |t|
    t.string  "username", limit: 45, null: false
    t.string  "password", limit: 45, null: false
    t.boolean "active",              null: false
  end

  create_table "widgets", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "stock"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
