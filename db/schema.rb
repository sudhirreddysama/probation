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

ActiveRecord::Schema.define(version: 20191219022838) do

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

  create_table "costcenters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "division"
    t.boolean "active",   default: true, null: false, unsigned: true
    t.string  "code"
    t.string  "name"
    t.index ["active"], name: "idx_active", using: :btree
    t.index ["code"], name: "idx_code", using: :btree
    t.index ["division"], name: "idx_division", using: :btree
  end

  create_table "customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "active",                                                   default: true, null: false, unsigned: true
    t.string  "division"
    t.integer "parent_id",                                                                            unsigned: true
    t.string  "id_path"
    t.string  "full_id_path"
    t.string  "path"
    t.string  "full_path"
    t.string  "name"
    t.string  "bill_to1"
    t.string  "bill_to2"
    t.string  "bill_to3"
    t.string  "bill_to4"
    t.string  "bill_to5"
    t.string  "ship_to1"
    t.string  "ship_to2"
    t.string  "ship_to3",          limit: 128
    t.string  "ship_to4"
    t.string  "ship_to5"
    t.string  "company"
    t.string  "primary_contact"
    t.string  "secondary_contact"
    t.string  "email"
    t.string  "phone"
    t.string  "fax"
    t.decimal "balance",                         precision: 15, scale: 2
    t.decimal "balance_total",                   precision: 15, scale: 2
    t.string  "account_no"
    t.string  "type"
    t.text    "notes",             limit: 65535
    t.string  "facility_address1"
    t.string  "facility_address2"
    t.string  "facility_address3"
    t.string  "facility_address4"
    t.string  "facility_address5"
    t.string  "contact_via"
    t.string  "ledger"
    t.index ["balance"], name: "idx_balance", using: :btree
    t.index ["division"], name: "idx_division", using: :btree
    t.index ["full_id_path"], name: "idx_full_id_path", using: :btree
  end

  create_table "db_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "obj_type"
    t.string "name"
    t.text   "notes",    limit: 65535
    t.index ["obj_type"], name: "idx_type", using: :btree
  end

  create_table "documents", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "user_id",                                                                                                          unsigned: true
    t.integer  "obj_id",                                                                                                           unsigned: true
    t.string   "obj_type"
    t.string   "name"
    t.datetime "created_at",                                                     default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean  "temporary",                                                      default: false,                      null: false, unsigned: true
    t.integer  "doc_template_id",                                                                                                  unsigned: true
    t.string   "action"
    t.boolean  "generated",                                                      default: false,                      null: false, unsigned: true
    t.text     "body",               limit: 4294967295
    t.integer  "sort",                                                           default: 0,                          null: false, unsigned: true
    t.integer  "doc_bulk_id",                                                                                                      unsigned: true
    t.decimal  "margin_left",                           precision: 10, scale: 5,                                                   unsigned: true
    t.decimal  "margin_right",                          precision: 10, scale: 5,                                                   unsigned: true
    t.decimal  "margin_top",                            precision: 10, scale: 5,                                                   unsigned: true
    t.decimal  "margin_bottom",                         precision: 10, scale: 5,                                                   unsigned: true
    t.string   "header_footer"
    t.boolean  "deliver",                                                        default: false,                      null: false, unsigned: true
    t.string   "deliver_via"
    t.string   "deliver_email"
    t.datetime "deliver_emailed_at"
    t.integer  "doc_delivery_id",                                                                                                  unsigned: true
    t.string   "role"
    t.boolean  "rendered_pdf",                                                   default: false,                      null: false, unsigned: true
    t.string   "type"
    t.string   "download_key"
    t.index ["obj_id", "obj_type"], name: "obj_id", length: { obj_type: 191 }, using: :btree
    t.index ["obj_id"], name: "project_id", using: :btree
  end

  create_table "holidays", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.date    "date"
    t.string  "name"
    t.boolean "county_only", default: false, null: false, unsigned: true
  end

  create_table "hs_changes", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer  "user_id",                                                                         unsigned: true
    t.datetime "created_at",                    default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string   "action"
    t.string   "obj_type"
    t.integer  "obj_id",                                                                          unsigned: true
    t.text     "values",     limit: 4294967295
    t.index ["obj_id"], name: "record_id", using: :btree
    t.index ["obj_type"], name: "record_type", length: { obj_type: 191 }, using: :btree
  end

  create_table "hs_ledgers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "active", default: true, null: false, unsigned: true
    t.string  "type"
    t.string  "code"
    t.string  "name"
    t.string  "config"
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
  end

  create_table "payeezy_posts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "previous_id",                                                                                                     unsigned: true
    t.string   "prev_type"
    t.string   "transaction_type"
    t.decimal  "dollar_amount",                        precision: 10, scale: 2
    t.string   "card_type"
    t.string   "card_name",              limit: 128
    t.string   "card_date"
    t.string   "card_last4"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "country_code"
    t.string   "phone"
    t.string   "phone_type"
    t.string   "prev_authorization_num"
    t.string   "prev_transaction_tag"
    t.string   "prev_transarmor_token"
    t.datetime "request_datetime"
    t.text     "request_body",           limit: 65535
    t.string   "response_code"
    t.text     "response_body",          limit: 65535
    t.text     "receipt",                limit: 65535
    t.string   "authorization_num"
    t.string   "transaction_tag"
    t.boolean  "transaction_approved",                                          default: false,                      null: false, unsigned: true
    t.string   "bank_code"
    t.string   "bank_message"
    t.string   "transarmor_token"
    t.string   "exact_code"
    t.string   "exact_message"
    t.datetime "created_at",                                                    default: -> { "CURRENT_TIMESTAMP" }
    t.index ["prev_type"], name: "idx_prev_type", using: :btree
    t.index ["transaction_approved"], name: "idx_transaction_approved", using: :btree
    t.index ["transaction_type"], name: "idx_transaction_type", using: :btree
  end

  create_table "sale_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "sale_id"
    t.integer "shot_id"
    t.integer "customer_id"
    t.text    "item_name",                  limit: 65535
    t.text    "item_description",           limit: 65535
    t.integer "qb_account_id",                                                                                  unsigned: true
    t.integer "qb_account2_id",                                                                                 unsigned: true
    t.string  "check_no"
    t.decimal "quantity",                                 precision: 10, scale: 2
    t.decimal "price",                                    precision: 15, scale: 2
    t.boolean "is_percent",                                                        default: false, null: false, unsigned: true
    t.decimal "amount",                                   precision: 15, scale: 2
    t.decimal "debit",                                    precision: 10, scale: 2
    t.decimal "credit",                                   precision: 10, scale: 2
    t.integer "sort"
    t.integer "payment_id",                                                                                     unsigned: true
    t.integer "payment_detail_id",                                                                              unsigned: true
    t.string  "type"
    t.boolean "split",                                                             default: false, null: false, unsigned: true
    t.text    "item_info",                  limit: 65535
    t.string  "division"
    t.string  "num"
    t.integer "sap_line_id",                                                                                    unsigned: true
    t.integer "pay_sap_line_id",                                                                                unsigned: true
    t.string  "cost_center"
    t.string  "debit_ledger"
    t.string  "credit_ledger"
    t.string  "document_letter"
    t.integer "previous_id",                                                                                    unsigned: true
    t.integer "qb_multi_invoice_detail_id",                                                                     unsigned: true
    t.integer "qb_late_fee_id",                                                                                 unsigned: true
    t.boolean "voided",                                                            default: false, null: false, unsigned: true
    t.integer "qb_late_fee_document_id",                                                                        unsigned: true
    t.index ["amount"], name: "idx_amount", using: :btree
    t.index ["customer_id"], name: "idx_qb_customer_id", using: :btree
    t.index ["pay_sap_line_id"], name: "idx_pay_sap_line_id", using: :btree
    t.index ["payment_detail_id"], name: "idx_payment_detail_id", using: :btree
    t.index ["payment_id"], name: "idx_payment_id", using: :btree
    t.index ["qb_account2_id"], name: "idx_qb_account2_id", using: :btree
    t.index ["qb_account_id"], name: "idx_qb_account_id", using: :btree
    t.index ["sale_id"], name: "idx_qb_transaction_id", using: :btree
    t.index ["sap_line_id"], name: "idx_sap_line_id", using: :btree
    t.index ["shot_id"], name: "idx_qb_item_price_id", using: :btree
    t.index ["type"], name: "idx_type", using: :btree
    t.index ["voided"], name: "idx_voided", using: :btree
  end

  create_table "sales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "division"
    t.integer  "customer_id"
    t.string   "num"
    t.string   "type"
    t.datetime "created_at",                                                    default: -> { "CURRENT_TIMESTAMP" }
    t.integer  "created_by_id",                                                                                                   unsigned: true
    t.datetime "updated_at"
    t.integer  "updated_by_id",                                                                                                   unsigned: true
    t.date     "date"
    t.date     "due_date"
    t.text     "memo",                   limit: 65535
    t.integer  "qb_account_id",                                                                                                   unsigned: true
    t.integer  "qb_account2_id",                                                                                                  unsigned: true
    t.string   "pay_method"
    t.decimal  "amount",                               precision: 15, scale: 2
    t.decimal  "split_amount",                         precision: 15, scale: 2
    t.decimal  "balance",                              precision: 15, scale: 2
    t.integer  "payment_id",                                                                                                      unsigned: true
    t.integer  "qb_multi_invoice_id",                                                                                             unsigned: true
    t.integer  "multi_sort",                                                    default: 0
    t.integer  "payeezy_post_id",                                                                                                 unsigned: true
    t.string   "cc_type"
    t.string   "cc_last4"
    t.string   "check_no"
    t.text     "notes",                  limit: 65535
    t.integer  "template_id"
    t.string   "classification"
    t.boolean  "voided",                                                        default: false,                      null: false, unsigned: true
    t.boolean  "paid",                                                          default: false,                      null: false, unsigned: true
    t.string   "terms"
    t.integer  "previous_id",                                                                                                     unsigned: true
    t.integer  "cc_previous_id",                                                                                                  unsigned: true
    t.string   "cc_option"
    t.date     "def_revenue_date"
    t.string   "cost_center"
    t.string   "debit_ledger"
    t.string   "credit_ledger"
    t.boolean  "late_fee_applied",                                              default: false,                      null: false, unsigned: true
    t.integer  "voided_payeezy_post_id",                                                                                          unsigned: true
    t.boolean  "late_auto",                                                     default: false,                      null: false, unsigned: true
    t.integer  "late_shot_id"
    t.string   "late_item_info"
    t.string   "late_item_name"
    t.string   "late_item_description"
    t.decimal  "late_amount",                          precision: 10, scale: 2
    t.string   "late_cost_center"
    t.string   "late_credit_ledger"
    t.string   "late_email"
    t.boolean  "pdf_previous",                                                  default: false,                      null: false, unsigned: true
    t.string   "payment_type"
    t.index ["balance"], name: "idx_balance", using: :btree
    t.index ["cc_previous_id"], name: "idx_previous_payeezy_post_id", using: :btree
    t.index ["cost_center"], name: "idx_qb_cost_center_id", using: :btree
    t.index ["created_by_id"], name: "idx_created_by_id", using: :btree
    t.index ["credit_ledger"], name: "idx_qb_gen_ledger_id", using: :btree
    t.index ["customer_id"], name: "idx_qb_customer_id", using: :btree
    t.index ["division"], name: "idx_division", using: :btree
    t.index ["num"], name: "idx_num", using: :btree
    t.index ["payeezy_post_id"], name: "idx_payeezy_post_id", using: :btree
    t.index ["previous_id"], name: "idx_previous_id", using: :btree
    t.index ["qb_account2_id"], name: "idx_qb_account2_id", using: :btree
    t.index ["qb_account_id"], name: "idx_qb_account_id", using: :btree
    t.index ["qb_multi_invoice_id"], name: "idx_qb_multi_invoice_id", using: :btree
    t.index ["type"], name: "idx_type", using: :btree
    t.index ["updated_by_id"], name: "idx_updated_by_id", using: :btree
  end

  create_table "sap_exports", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "sap_lines_count",                                                         unsigned: true
    t.datetime "created_at",                         default: -> { "CURRENT_TIMESTAMP" }
    t.date     "cutoff_date"
    t.text     "data",            limit: 4294967295
  end

  create_table "sap_lines", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "sap_export_id",                                          unsigned: true
    t.string   "cost_center"
    t.string   "credit"
    t.string   "reference"
    t.string   "reference_key1"
    t.text     "text",            limit: 65535
    t.string   "document_header"
    t.string   "debit"
    t.date     "posting_date"
    t.string   "assignment"
    t.string   "reference_key2"
    t.string   "reference_key3"
    t.decimal  "amount",                        precision: 10, scale: 2
    t.datetime "invoice_date"
    t.string   "customer"
    t.boolean  "resent",                                                 unsigned: true
    t.index ["sap_export_id"], name: "idx_sap_export_id", using: :btree
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "session_id", limit: 191,   default: "", null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "idx_session_id", using: :btree
  end

  create_table "shots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "active",                                 default: true,  null: false, unsigned: true
    t.string  "division"
    t.integer "parent_id",                                                           unsigned: true
    t.string  "id_path"
    t.string  "full_id_path"
    t.string  "path"
    t.string  "full_path"
    t.string  "name"
    t.string  "description"
    t.string  "type"
    t.integer "qb_account_id",                                                       unsigned: true
    t.decimal "price",         precision: 15, scale: 2
    t.boolean "is_percent",                             default: false, null: false, unsigned: true
    t.string  "ledger"
    t.string  "cost_center"
    t.index ["division"], name: "idx_division", using: :btree
    t.index ["qb_account_id"], name: "idx_qb_account_id", using: :btree
  end

  create_table "status", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "status"
    t.string   "status_description"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "supervisors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "first_phone"
    t.string   "second_phone"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "users", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "username"
    t.string   "password_digest"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "phone"
    t.string   "level"
    t.boolean  "active",             default: true,  null: false, unsigned: true
    t.string   "activation_key"
    t.datetime "last_login_at"
    t.datetime "password_set_at"
    t.boolean  "auth_ldap",          default: false, null: false, unsigned: true
    t.string   "qb_level"
    t.string   "ve_level"
    t.date     "valid_until"
    t.string   "deliver_from_name"
    t.string   "deliver_from_email"
  end

end
