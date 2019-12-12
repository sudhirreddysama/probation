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

ActiveRecord::Schema.define(version: 20191212022836) do

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

  create_table "db_group_objs1", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "db_group_id", unsigned: true
    t.string  "obj_type"
    t.integer "obj_id",      unsigned: true
    t.index ["db_group_id"], name: "idx_db_group_id", using: :btree
    t.index ["obj_id"], name: "idx_obj_id", using: :btree
    t.index ["obj_type"], name: "idx_obj_type", using: :btree
  end

  create_table "db_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "obj_type"
    t.string "name"
    t.text   "notes",    limit: 65535
    t.index ["obj_type"], name: "idx_type", using: :btree
  end

  create_table "doc_bulks1", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                                                                                          unsigned: true
    t.integer  "doc_template_id",                                                                                  unsigned: true
    t.string   "action"
    t.string   "name"
    t.datetime "created_at",                                                  default: -> { "CURRENT_TIMESTAMP" }
    t.text     "body",            limit: 4294967295
    t.decimal  "margin_left",                        precision: 10, scale: 5,                                      unsigned: true
    t.decimal  "margin_right",                       precision: 10, scale: 5,                                      unsigned: true
    t.decimal  "margin_top",                         precision: 10, scale: 5,                                      unsigned: true
    t.decimal  "margin_bottom",                      precision: 10, scale: 5,                                      unsigned: true
    t.string   "header_footer"
    t.string   "obj_type"
  end

  create_table "doc_deliveries1", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at",      default: -> { "CURRENT_TIMESTAMP" }
    t.integer  "user_id",                                                           unsigned: true
    t.integer  "documents_count", default: 0,                          null: false, unsigned: true
    t.integer  "email_count",     default: 0,                          null: false, unsigned: true
    t.integer  "postal_count",    default: 0,                          null: false, unsigned: true
    t.integer  "both_count",      default: 0,                          null: false, unsigned: true
    t.string   "from_email"
    t.string   "from_name"
    t.string   "deliver_via",     default: "0",                        null: false
  end

  create_table "doc_templates1", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name"
    t.text    "body",          limit: 4294967295
    t.decimal "margin_left",                      precision: 10, scale: 5,                              unsigned: true
    t.decimal "margin_right",                     precision: 10, scale: 5,                              unsigned: true
    t.decimal "margin_top",                       precision: 10, scale: 5,                              unsigned: true
    t.decimal "margin_bottom",                    precision: 10, scale: 5,                              unsigned: true
    t.string  "header_footer"
    t.string  "obj_type"
    t.boolean "deliver",                                                   default: false, null: false, unsigned: true
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

  create_table "eh_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "name2"
    t.string "division"
  end

  create_table "eh_customers", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "active_status"
    t.boolean "has_transactions",                   default: false, null: false, unsigned: true
    t.string  "category",               limit: 128
    t.string  "category2",              limit: 128
    t.string  "customer",               limit: 128
    t.string  "customer2",              limit: 128
    t.integer "category_id",                                                     unsigned: true
    t.string  "customer_raw"
    t.string  "balance"
    t.string  "balance_total"
    t.string  "notes"
    t.string  "company"
    t.string  "prefix"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "main_phone"
    t.string  "work_phone"
    t.string  "mobile"
    t.string  "fax"
    t.string  "alt_phone"
    t.string  "alt_mobile"
    t.string  "main_email"
    t.string  "cc_email"
    t.string  "primary_contact"
    t.string  "secondary_contact"
    t.string  "job_title"
    t.string  "bill_to1"
    t.string  "bill_to2"
    t.string  "bill_to3"
    t.string  "bill_to4"
    t.string  "bill_to5"
    t.string  "bill_to"
    t.string  "street1"
    t.string  "street2"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.string  "ship_to1"
    t.string  "ship_to2"
    t.string  "ship_to3"
    t.string  "ship_to4"
    t.string  "ship_to"
    t.string  "ship_to_street1"
    t.string  "ship_to_street2"
    t.string  "ship_to_city"
    t.string  "ship_to_state"
    t.string  "ship_to_zip"
    t.string  "sales_tax_code"
    t.string  "account_no"
    t.string  "customer_type"
    t.string  "terms"
    t.string  "note"
    t.string  "days_overdue"
    t.string  "facility_address_line1"
    t.string  "facility_address_line2"
    t.string  "facility_address_line3"
    t.string  "facility_address_line4"
    t.string  "job_type"
    t.string  "division"
    t.index ["account_no"], name: "idx_account_no", using: :btree
    t.index ["category"], name: "idx_category", using: :btree
    t.index ["customer_raw"], name: "customer_raw", using: :btree
    t.index ["facility_address_line1"], name: "idx_facility_address_line1", using: :btree
    t.index ["facility_address_line2"], name: "idx_facility_address_line2", using: :btree
  end

  create_table "eh_customers_old", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "active"
    t.string  "category"
    t.string  "category2"
    t.string  "customer_raw"
    t.string  "customer",          limit: 128
    t.string  "customer2",         limit: 128
    t.string  "balance"
    t.string  "balance_total"
    t.string  "company"
    t.string  "prefix"
    t.string  "first_name"
    t.string  "middle_name"
    t.string  "last_name"
    t.string  "primary_contact"
    t.string  "main_phone"
    t.string  "fax"
    t.string  "alt_phone"
    t.string  "secondary_contact"
    t.string  "job_title"
    t.string  "mail_email"
    t.string  "bill_to1"
    t.string  "bill_to2"
    t.string  "bill_to3"
    t.string  "bill_to4"
    t.string  "bill_to5"
    t.string  "ship_to1"
    t.string  "ship_to2"
    t.string  "ship_to3"
    t.string  "ship_to4"
    t.string  "ship_to5"
    t.string  "customer_type"
    t.string  "terms"
    t.string  "rep"
    t.string  "sales_tax_code"
    t.string  "tax_item"
    t.string  "resale_num"
    t.string  "account_no"
    t.string  "credit_limit"
    t.string  "job_status"
    t.string  "job_type"
    t.string  "job_description"
    t.string  "start_date"
    t.string  "projected_end"
    t.string  "end_date"
    t.string  "division"
    t.integer "category_id",                   unsigned: true
    t.index ["customer_raw"], name: "customer", using: :btree
  end

  create_table "eh_transactions", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "trans_no"
    t.string  "type"
    t.string  "entered_modified"
    t.string  "last_modified_by"
    t.string  "date_raw"
    t.date    "date"
    t.string  "num"
    t.string  "name"
    t.string  "source_name"
    t.string  "name_address"
    t.string  "name_street1"
    t.string  "name_street2"
    t.string  "name_city"
    t.string  "name_state"
    t.string  "name_zip"
    t.string  "name_contact"
    t.string  "name_phone"
    t.string  "name_fax"
    t.string  "name_email"
    t.string  "name_account_no"
    t.string  "memo"
    t.string  "ship_date"
    t.string  "via"
    t.string  "terms"
    t.string  "due_date"
    t.string  "item"
    t.string  "item_description"
    t.string  "account"
    t.string  "sales_tax_code"
    t.string  "clr"
    t.string  "billing_status"
    t.string  "split"
    t.string  "print"
    t.string  "paid"
    t.string  "pay_meth"
    t.string  "aging"
    t.string  "open_balance"
    t.string  "qty"
    t.string  "sales_price"
    t.string  "debit"
    t.string  "credit"
    t.string  "amount"
    t.string  "balance"
    t.string  "account_type"
    t.string  "action"
    t.string  "backordered"
    t.string  "ship_to_city"
    t.string  "ship_to_address1"
    t.string  "ship_to_address2"
    t.string  "ship_to_state"
    t.string  "ship_zip"
    t.string  "check_no"
    t.string  "facility_address_line1"
    t.string  "facility_address_line2"
    t.string  "facility_address_line3"
    t.string  "facility_address_line4"
    t.string  "division"
    t.integer "customer_id",            unsigned: true
    t.index ["customer_id"], name: "customer_id", using: :btree
    t.index ["name"], name: "name", using: :btree
    t.index ["num"], name: "idx_num", using: :btree
  end

  create_table "eh_transactions_old", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "type"
    t.string  "date"
    t.string  "num"
    t.string  "name"
    t.string  "memo"
    t.string  "account"
    t.string  "clr"
    t.string  "split"
    t.string  "amount"
    t.string  "balance"
    t.string  "division"
    t.integer "customer_id", unsigned: true
    t.index ["customer_id"], name: "customer_id", using: :btree
    t.index ["name"], name: "name", using: :btree
  end

  create_table "fd_activities", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "fd_establishment_id",                                                      unsigned: true
    t.string   "gaz_number"
    t.string   "inspection_type"
    t.integer  "fd_inspection_code_id",                                                    unsigned: true
    t.date     "activity_date"
    t.date     "complaint_received"
    t.date     "complaint_abate"
    t.integer  "length"
    t.string   "inspector_init",        limit: 100
    t.date     "reinspection_due_date"
    t.text     "notes",                 limit: 65535
    t.datetime "created_at",                          default: -> { "CURRENT_TIMESTAMP" }
    t.string   "ehipssent",             limit: 100
    t.string   "operation_id",          limit: 12
    t.index ["gaz_number"], name: "idx_gaz_number", using: :btree
  end

  create_table "fd_churches", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "church_name"
    t.string "address"
    t.string "city"
    t.string "zipcode"
    t.date   "issue_date"
    t.date   "expiration_date"
  end

  create_table "fd_establishments", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "gaz_number"
    t.string  "estab_name"
    t.string  "estab_address"
    t.string  "estab_city"
    t.string  "estab_zip"
    t.string  "status"
    t.date    "date_ob"
    t.boolean "ob_to_ehips",                        default: false, null: false, unsigned: true
    t.string  "capacity_rate"
    t.date    "date_estab_open"
    t.integer "seating_cap"
    t.string  "san_init"
    t.date    "date_permit"
    t.date    "permit_exp"
    t.string  "certificate",             limit: 1
    t.string  "estab_type_code"
    t.string  "estab_phone"
    t.string  "risk",                    limit: 1
    t.string  "estab_type"
    t.date    "last_insp"
    t.string  "prefixgaz"
    t.string  "facility_code"
    t.string  "facility_name"
    t.string  "gazcode"
    t.string  "street_number"
    t.string  "street_name"
    t.string  "street_num_name"
    t.string  "street_type"
    t.string  "street_direction"
    t.string  "fac_city"
    t.string  "fac_zip"
    t.string  "water_id"
    t.string  "primary_op"
    t.string  "estab_state"
    t.string  "fee_type",                limit: 1
    t.string  "customer_acct_no"
    t.date    "billing_date"
    t.date    "date_paid"
    t.string  "rec_no"
    t.string  "check_no"
    t.string  "fee_receipt_comment"
    t.string  "owner_name"
    t.string  "owner_addr"
    t.string  "owner_zip"
    t.string  "owner_city"
    t.string  "owner_state"
    t.string  "email1"
    t.string  "email2"
    t.string  "exclude_permit_print"
    t.string  "exclude_permit_print2"
    t.date    "prev_issue_date"
    t.date    "prev_expire_date"
    t.date    "timetab"
    t.string  "operation_id",            limit: 12
    t.date    "date_application_recvd"
    t.date    "workers_comp_exp"
    t.date    "disability_exp"
    t.date    "exemption_cert_exp"
    t.date    "permit_sent_date"
    t.string  "mobtype"
    t.date    "date_cc_info_to_billing"
    t.integer "qb_customer_id",                                                  unsigned: true
    t.index ["facility_name"], name: "idx_facility_name", using: :btree
    t.index ["gaz_number"], name: "idx_gaz_number", using: :btree
    t.index ["qb_customer_id"], name: "idx_customer_id", using: :btree
  end

  create_table "fd_fee_schedules", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "facility_type"
    t.string  "facility_type_code"
    t.string  "type"
    t.string  "description"
    t.integer "min",                                         default: 0
    t.integer "max",                                         default: 0
    t.string  "fee_code"
    t.decimal "fee",                precision: 10, scale: 2
    t.decimal "late_fee",           precision: 10, scale: 2
  end

  create_table "fd_inspection_codes", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "name",       limit: 100
    t.integer "ehips_link"
  end

  create_table "fd_plan_reviews", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "gaz_number"
    t.string "owner_name"
    t.string "owner_address"
    t.string "owner_city"
    t.string "owner_state"
    t.string "owner_zip"
    t.string "estab_name"
    t.string "estab_address"
    t.string "estab_city"
    t.string "estab_state"
    t.string "estab_zip"
    t.string "receipt_no"
    t.string "check_no"
    t.string "date_received"
    t.string "amount_received"
    t.string "inspector"
    t.string "service"
    t.string "plan_number"
    t.string "architect/engineer_name"
    t.string "operator_name"
    t.string "date_of_issue"
    t.string "date_cc_info_to_billing"
    t.string "s_guid"
  end

  create_table "fd_towns", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "facility_name"
    t.string "address"
    t.string "type"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "street_no"
    t.string "street_name"
    t.string "street_type"
    t.string "street_dir"
    t.string "fac_code"
    t.string "town"
    t.string "name"
    t.string "code"
  end

  create_table "fd_waivers", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "date"
    t.string "town"
    t.string "organization"
    t.string "address"
    t.string "city"
    t.string "zip"
    t.string "person_sig"
    t.string "title"
    t.string "charitable"
    t.string "government"
    t.string "waiver_rej"
    t.string "revision__date"
    t.string "exempt"
    t.string "s_guid"
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

  create_table "inventories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "obj_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "obj_type"
    t.string "name"
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

  create_table "pl_fee_schedules", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "facility_type"
    t.decimal "fee",           precision: 10, scale: 2
    t.decimal "half_fee",      precision: 10, scale: 2
    t.decimal "late_fee",      precision: 10, scale: 2
  end

  create_table "pl_pools", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "ehips_operation_id"
    t.string  "pool_name"
    t.string  "pool_address"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.string  "municipality"
    t.string  "facility_name"
    t.string  "facility_type"
    t.boolean "nonseasonal",                                               default: false, null: false, unsigned: true
    t.string  "state_id"
    t.string  "facility_code"
    t.boolean "diving_board",                                              default: false, null: false, unsigned: true
    t.string  "board_approved"
    t.string  "inspector"
    t.string  "contact_person"
    t.string  "title"
    t.string  "email1"
    t.string  "email2"
    t.string  "phone"
    t.string  "pool_opera"
    t.string  "operation_key"
    t.string  "category"
    t.string  "subcategory"
    t.boolean "primary_op",                                                default: false, null: false, unsigned: true
    t.date    "safety_plan_recd"
    t.boolean "primary_pool_op",                                           default: false, null: false, unsigned: true
    t.string  "ehips_op_key"
    t.string  "supervision"
    t.string  "size"
    t.integer "surface_area",                                                                           unsigned: true
    t.decimal "min_depth",                        precision: 10, scale: 2,                              unsigned: true
    t.decimal "max_depth",                        precision: 10, scale: 2,                              unsigned: true
    t.integer "capacity_gal",                                                                           unsigned: true
    t.integer "turnoverrate_min",                                                                       unsigned: true
    t.integer "bather_load",                                                                            unsigned: true
    t.string  "tile"
    t.string  "concrete"
    t.string  "make_of_filter"
    t.string  "number"
    t.decimal "filter_rate",                      precision: 10, scale: 2,                              unsigned: true
    t.string  "disinfection"
    t.string  "coagulant"
    t.string  "water_source"
    t.string  "freshwater"
    t.string  "waste_to"
    t.text    "comments",           limit: 65535
    t.string  "plan"
    t.string  "plan_location"
    t.string  "number2"
    t.string  "active",             limit: 1
    t.string  "bill_to"
    t.string  "bill_address"
    t.string  "bill_city"
    t.string  "bill_state"
    t.string  "bill_zip"
    t.string  "fee_exempt",         limit: 1
    t.integer "offlinesort"
    t.string  "permit_key"
    t.string  "facility_key"
    t.string  "update_val",         limit: 1
    t.date    "issue_date"
    t.date    "expiration_date"
    t.date    "app_recd_date"
    t.date    "perm_mail_date"
    t.date    "paid_date"
    t.date    "wc_recd_ok"
    t.date    "db_recd_ok"
    t.integer "qb_customer_id",                                                                         unsigned: true
  end

  create_table "pl_supervision_levels", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.text   "text", limit: 4294967295
    t.string "code"
  end

  create_table "qb_accounts1", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "active",                                  default: true, null: false, unsigned: true
    t.string  "division"
    t.integer "parent_id",                                                           unsigned: true
    t.string  "id_path"
    t.string  "full_id_path"
    t.string  "path"
    t.string  "full_path"
    t.string  "name"
    t.string  "type"
    t.decimal "balance",        precision: 10, scale: 2
    t.decimal "balance_total",  precision: 10, scale: 2
    t.string  "description"
    t.string  "account_no"
    t.string  "bank_no"
    t.string  "invoice_prefix"
    t.index ["division"], name: "idx_division", using: :btree
  end

  create_table "qb_late_fees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "division"
    t.datetime "created_at",                                            default: -> { "CURRENT_TIMESTAMP" }
    t.integer  "shot_id"
    t.integer  "qb_transaction_details_count",                                                                            unsigned: true
    t.string   "item_info"
    t.string   "item_name"
    t.string   "item_description"
    t.decimal  "amount",                       precision: 10, scale: 2
    t.string   "credit_ledger"
    t.string   "cost_center"
    t.decimal  "total",                        precision: 10, scale: 2
    t.boolean  "doc_generate",                                          default: true,                       null: false, unsigned: true
    t.boolean  "doc_deliver",                                           default: true,                       null: false, unsigned: true
    t.integer  "user_id",                                                                                                 unsigned: true
  end

  create_table "qb_multi_invoice_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "qb_multi_invoice_id",                                                       unsigned: true
    t.integer "shot_id"
    t.string  "item_name"
    t.string  "item_description"
    t.decimal "quantity",            precision: 10, scale: 2
    t.decimal "price",               precision: 15, scale: 2
    t.boolean "is_percent",                                   default: false, null: false, unsigned: true
    t.decimal "amount",              precision: 15, scale: 2
    t.integer "sort"
    t.string  "item_info"
    t.string  "cost_center"
    t.string  "credit_ledger"
  end

  create_table "qb_multi_invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "division"
    t.date    "date"
    t.integer "qb_account_id",                                                               unsigned: true
    t.string  "name"
    t.decimal "amount",                precision: 15, scale: 2
    t.integer "qb_template_id",                                                              unsigned: true
    t.integer "qb_cost_center_id",                                                           unsigned: true
    t.date    "def_revenue_date"
    t.string  "cost_center"
    t.string  "debit_ledger"
    t.string  "credit_ledger"
    t.date    "due_date"
    t.string  "num"
    t.boolean "late_auto",                                      default: false, null: false, unsigned: true
    t.integer "last_shot_id"
    t.string  "late_item_info"
    t.string  "late_item_name"
    t.string  "late_item_description"
    t.decimal "late_amount",           precision: 10, scale: 2, default: "0.0"
    t.string  "late_cost_center"
    t.string  "late_credit_ledger"
    t.string  "late_email"
    t.string  "memo"
    t.string  "doc_deliver_via"
    t.index ["debit_ledger"], name: "idx_qb_gen_ledger_id", using: :btree
    t.index ["qb_account_id"], name: "idx_qb_account_id", using: :btree
    t.index ["qb_cost_center_id"], name: "idx_qb_cost_center_id", using: :btree
    t.index ["qb_template_id"], name: "idx_qb_template_id", using: :btree
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

  create_table "saved_filters1", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "type"
    t.binary   "data",       limit: 4294967295
    t.integer  "user_id",                                                                         unsigned: true
    t.datetime "created_at",                    default: -> { "CURRENT_TIMESTAMP" }
    t.boolean  "shared",                        default: false,                      null: false, unsigned: true
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

  create_table "systems", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "doc_render_working", default: false, null: false, unsigned: true
    t.boolean "doc_email_working",  default: false, null: false, unsigned: true
  end

  create_table "templates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "division"
    t.string  "name"
    t.text    "address",               limit: 65535
    t.string  "phone"
    t.boolean "active",                                                       default: true,  null: false, unsigned: true
    t.string  "label_head_name"
    t.string  "label_head_fac"
    t.boolean "show_head_name",                                               default: false, null: false, unsigned: true
    t.boolean "show_head_fac",                                                default: false, null: false, unsigned: true
    t.string  "label_foot_name"
    t.string  "label_foot_num"
    t.boolean "show_foot_name",                                               default: false, null: false, unsigned: true
    t.boolean "show_foot_num",                                                default: false, null: false, unsigned: true
    t.string  "label_item_info"
    t.string  "label_item_name"
    t.string  "label_item_desc"
    t.string  "label_item_quantity"
    t.string  "label_item_price"
    t.string  "label_item_amount"
    t.boolean "show_item_info",                                               default: false, null: false, unsigned: true
    t.boolean "show_item_name",                                               default: true,  null: false, unsigned: true
    t.boolean "show_item_desc",                                               default: true,  null: false, unsigned: true
    t.boolean "show_item_quantity",                                           default: true,  null: false, unsigned: true
    t.boolean "show_item_price",                                              default: true,  null: false, unsigned: true
    t.boolean "show_item_amount",                                             default: true,  null: false, unsigned: true
    t.string  "sale_num"
    t.string  "refund_num"
    t.string  "invoice_num"
    t.string  "payment_num"
    t.string  "ar_refund_num"
    t.string  "cost_center"
    t.boolean "late_auto",                                                    default: false, null: false, unsigned: true
    t.integer "last_shot_id"
    t.string  "late_item_info"
    t.string  "late_item_name"
    t.string  "late_item_description"
    t.decimal "late_amount",                         precision: 10, scale: 2
    t.string  "late_cost_center"
    t.string  "late_credit_ledger"
    t.string  "late_email"
    t.string  "checks_to"
    t.text    "footer_text",           limit: 65535
    t.index ["active"], name: "idx_active", using: :btree
    t.index ["cost_center"], name: "idx_cost_center", using: :btree
    t.index ["division"], name: "idx_division", using: :btree
  end

  create_table "tf_facilities", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "operator_name"
    t.string   "food_stand"
    t.string   "operator_address"
    t.string   "operator_city"
    t.string   "operator_zip"
    t.string   "operator_phone"
    t.string   "event_name"
    t.string   "event_booth_site"
    t.string   "event_town"
    t.string   "risk_class"
    t.string   "inspector"
    t.date     "inspect_date"
    t.integer  "inspect_duration"
    t.text     "violations_cited",             limit: 65535
    t.date     "issue_date"
    t.date     "expire_date"
    t.string   "temp_permit_number"
    t.string   "type_of_facility"
    t.string   "food_items"
    t.string   "receipt_number"
    t.string   "receipt_number1"
    t.string   "receipt_number2"
    t.date     "date_paid"
    t.decimal  "amount_paid",                                precision: 11, scale: 2, default: "0.0"
    t.string   "check_number"
    t.text     "file_notes",                   limit: 65535
    t.datetime "created_at",                                                          default: -> { "CURRENT_TIMESTAMP" }
    t.string   "waiver"
    t.date     "workers_comp_exp"
    t.date     "disability_exp"
    t.date     "exemption_cert_exp"
    t.date     "wrkrs_comp_cancellation_date"
    t.date     "disability_cancellation_date"
    t.integer  "qb_customer_id",                                                                                           unsigned: true
    t.index ["receipt_number"], name: "idx_receipt_number", length: { receipt_number: 191 }, using: :btree
    t.index ["receipt_number1"], name: "idx_receipt_number1", length: { receipt_number1: 191 }, using: :btree
    t.index ["receipt_number2"], name: "idx_receipt_number2", length: { receipt_number2: 191 }, using: :btree
    t.index ["temp_permit_number"], name: "idx_temp_permit_number", length: { temp_permit_number: 191 }, using: :btree
  end

  create_table "tf_violation_types", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "code_section"
    t.text   "violation",    limit: 65535
    t.string "red_blue"
  end

  create_table "tf_violations", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text     "violation",            limit: 65535
    t.string   "code_section"
    t.date     "action_date"
    t.boolean  "corrected",                          default: false,                      unsigned: true
    t.string   "red_blue",             limit: 100
    t.integer  "tf_violation_type_id",                                                    unsigned: true
    t.datetime "created_at",                         default: -> { "CURRENT_TIMESTAMP" }
    t.integer  "tf_facility_id",                                                          unsigned: true
    t.integer  "sort",                                                                    unsigned: true
  end

  create_table "tr_activities", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "obj_id",                               unsigned: true
    t.string  "obj_type"
    t.string  "fac_no"
    t.string  "facility_name"
    t.string  "facility_type"
    t.string  "activity_type"
    t.date    "activity_date"
    t.string  "s_u",                    limit: 1
    t.string  "staff_initials"
    t.text    "notes",                  limit: 65535
    t.integer "daycare_red_violations"
    t.date    "reinspection_due"
  end

  create_table "tr_child_camps", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "fac_no"
    t.string  "facility_name"
    t.string  "facility_address"
    t.string  "location"
    t.string  "fac_zip"
    t.string  "phone"
    t.boolean "active",                                                                   default: true,  null: false, unsigned: true
    t.string  "operator_owner"
    t.string  "operator_addr"
    t.string  "operator_city"
    t.string  "operator_zip"
    t.string  "operator_phone"
    t.string  "contact"
    t.string  "town"
    t.string  "ein_ss"
    t.string  "email1"
    t.string  "facility_type"
    t.date    "open_date"
    t.date    "close_date"
    t.date    "appl_sent"
    t.date    "appl_recd"
    t.integer "capacity"
    t.integer "sessions"
    t.decimal "fee",                                             precision: 10, scale: 2
    t.string  "fee_paid"
    t.boolean "permit",                                                                   default: false, null: false, unsigned: true
    t.string  "preop_status"
    t.date    "preop_insp"
    t.string  "preop_s_u",                         limit: 1
    t.date    "oper_insp"
    t.string  "oper_s_u",                          limit: 1
    t.date    "oper_reinsp"
    t.string  "inspector"
    t.string  "reviewed_by"
    t.boolean "doh_3965",                                                                 default: false, null: false, unsigned: true
    t.boolean "wc_db_recd",                                                               default: false, null: false, unsigned: true
    t.boolean "doh_2271",                                                                 default: false, null: false, unsigned: true
    t.boolean "ldss_3370",                                                                default: false, null: false, unsigned: true
    t.boolean "dss_ans",                                                                  default: false, null: false, unsigned: true
    t.boolean "doh_367",                                                                  default: false, null: false, unsigned: true
    t.boolean "manual_ok",                                                                default: false, null: false, unsigned: true
    t.boolean "manual_update",                                                            default: false, null: false, unsigned: true
    t.boolean "safety_plan_disability_adn",                                               default: false, null: false, unsigned: true
    t.boolean "covered_amusement_devices",                                                default: false, null: false, unsigned: true
    t.boolean "amusement_devices_form",                                                   default: false, null: false, unsigned: true
    t.string  "camp_director"
    t.string  "health_director"
    t.string  "aquatics_director"
    t.boolean "aquatics_dir_required",                                                                                 unsigned: true
    t.string  "pool_operator"
    t.boolean "first_aid_certifications_received",                                        default: false, null: false, unsigned: true
    t.boolean "cpr_cert",                                                                 default: false, null: false, unsigned: true
    t.boolean "lifeguard_psi_certifications",                                             default: false, null: false, unsigned: true
    t.boolean "aquatics_director_certs",                                                  default: false, null: false, unsigned: true
    t.boolean "counselor_to_camper_ratio",                                                default: false, null: false, unsigned: true
    t.string  "food_service"
    t.text    "comments",                          limit: 65535
    t.integer "qb_customer_id",                                                                                        unsigned: true
  end

  create_table "tr_daycares", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "fac_no"
    t.string  "facility_name"
    t.string  "facility_address"
    t.string  "location"
    t.string  "fac_zip"
    t.string  "phone"
    t.boolean "active",                                                              default: true,  null: false, unsigned: true
    t.string  "operator_owner"
    t.string  "operator_addr"
    t.string  "operator_city"
    t.string  "operator_zip"
    t.string  "operator_phone"
    t.string  "contact"
    t.date    "activation_date"
    t.date    "deactivation_date"
    t.string  "email1"
    t.string  "email2"
    t.integer "capacity"
    t.boolean "profit",                                                              default: false, null: false, unsigned: true
    t.decimal "fee",                                        precision: 10, scale: 2
    t.string  "fee_code"
    t.date    "date_to_bus"
    t.date    "invoice_date"
    t.string  "invoice"
    t.string  "inspector"
    t.date    "annual_insp"
    t.string  "annual_s_u",                   limit: 1
    t.date    "reinsp_1st"
    t.string  "reinsp_1st_s_u",               limit: 1
    t.date    "partial_insp"
    t.date    "reinsp_2nd"
    t.string  "reinsp_2nd_s_u",               limit: 1
    t.date    "reinsp_3rd"
    t.string  "reinsp_3rd_s_u",               limit: 1
    t.date    "annual_2nd_insp"
    t.string  "annual_2nd_s_u",               limit: 1
    t.date    "preop_insp"
    t.string  "preop_s_u",                    limit: 1
    t.string  "operation_id"
    t.string  "building_age"
    t.date    "lead_program_ref_date"
    t.date    "lead_inspection_date"
    t.string  "lead_inspection_results"
    t.date    "lead_clearance_date"
    t.string  "inspector_contact"
    t.string  "food_service_estab",           limit: 1
    t.boolean "food_service_permit",                                                                              unsigned: true
    t.boolean "food_catered",                                                                                     unsigned: true
    t.date    "food_plan_receipt_date"
    t.date    "food_plan_approval_date"
    t.text    "food_service_description",     limit: 65535
    t.text    "food_plan_corrective_actions", limit: 65535
    t.text    "comments",                     limit: 65535
    t.integer "qb_customer_id",                                                                                   unsigned: true
  end

  create_table "tr_fee_schedules", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "facility_type"
    t.string  "description"
    t.string  "fee_code"
    t.decimal "fee",            precision: 10, scale: 2
    t.decimal "additional_fee", precision: 10, scale: 2
    t.integer "min"
    t.integer "max"
  end

  create_table "tr_others", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "fac_no"
    t.string   "facility_name"
    t.string   "facility_address"
    t.string   "location"
    t.string   "fac_zip"
    t.string   "phone"
    t.boolean  "active",                                              default: true,  null: false, unsigned: true
    t.string   "operator_owner"
    t.string   "operator_addr"
    t.string   "operator_city"
    t.string   "operator_zip"
    t.string   "operator_phone"
    t.string   "contact"
    t.string   "town"
    t.date     "activation_date"
    t.date     "deactivation_date"
    t.string   "ein_ss"
    t.string   "email1"
    t.string   "email2"
    t.string   "facility_type"
    t.integer  "capacity"
    t.decimal  "fee",                        precision: 10, scale: 2
    t.string   "fee_code"
    t.date     "appl_sent"
    t.date     "appl_recd"
    t.date     "permit_sent"
    t.date     "permit_issue"
    t.date     "permit_exp"
    t.string   "in_operation"
    t.string   "code"
    t.date     "wc_expiration_date"
    t.date     "disability_expiration_date"
    t.date     "last_annual_insp"
    t.string   "fac_key"
    t.string   "operation_id"
    t.string   "cat"
    t.string   "subcat"
    t.string   "phoneno"
    t.boolean  "primaryop",                                           default: false,              unsigned: true
    t.string   "customer_acct_no"
    t.decimal  "fee_paid",                   precision: 10, scale: 2
    t.datetime "date_paid"
    t.boolean  "pool",                                                                             unsigned: true
    t.string   "comments"
    t.integer  "qb_customer_id",                                                                   unsigned: true
  end

  create_table "tr_tannings", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "fac_no"
    t.string  "facility_name"
    t.string  "facility_address"
    t.string  "location"
    t.string  "fac_zip"
    t.string  "phone"
    t.boolean "active",                                                            default: true, null: false, unsigned: true
    t.string  "operator_owner"
    t.string  "operator_addr"
    t.string  "operator_city"
    t.string  "operator_zip"
    t.string  "operator_phone"
    t.string  "contact"
    t.string  "town"
    t.date    "activation_date"
    t.date    "deactivation_date"
    t.string  "ein_ss"
    t.date    "appl_sent"
    t.date    "appl_recd"
    t.date    "permit_sent"
    t.date    "permit_issue"
    t.date    "permit_exp"
    t.date    "preop_insp"
    t.date    "annual_insp"
    t.string  "s_u"
    t.date    "reinspection"
    t.string  "partial_s_u"
    t.date    "reinspection_2nd"
    t.string  "reinspection_2nd_s_u"
    t.date    "complaint_date"
    t.date    "abate_date"
    t.date    "wc_expiration_date"
    t.date    "disability_expiration_date"
    t.integer "num_units"
    t.decimal "total_fee",                                precision: 10, scale: 2
    t.decimal "fee_paid",                                 precision: 10, scale: 2
    t.date    "date_paid"
    t.date    "last_annual_insp"
    t.text    "comments",                   limit: 65535
    t.integer "qb_customer_id",                                                                                unsigned: true
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

  create_table "ve_events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "ve_reservation_id",               unsigned: true
    t.integer "ve_vehicle_id",                   unsigned: true
    t.date    "date"
    t.time    "begin_time"
    t.time    "end_time"
    t.text    "notes",             limit: 65535
    t.index ["ve_reservation_id"], name: "idx_ve_reservation_id", using: :btree
    t.index ["ve_vehicle_id"], name: "idx_ve_vehicle_id", using: :btree
  end

  create_table "ve_mileages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "ve_vehicle_id", unsigned: true
    t.integer "year"
    t.integer "year_start",    unsigned: true
    t.integer "jan",           unsigned: true
    t.integer "feb",           unsigned: true
    t.integer "mar",           unsigned: true
    t.integer "apr",           unsigned: true
    t.integer "may",           unsigned: true
    t.integer "jun",           unsigned: true
    t.integer "jul",           unsigned: true
    t.integer "aug",           unsigned: true
    t.integer "sep",           unsigned: true
    t.integer "oct",           unsigned: true
    t.integer "nov",           unsigned: true
    t.integer "dec",           unsigned: true
    t.index ["ve_vehicle_id", "year"], name: "idx_ve_vehicle_id_year", unique: true, using: :btree
    t.index ["ve_vehicle_id"], name: "idx_vehicle_id", using: :btree
    t.index ["year"], name: "idx_year", using: :btree
  end

  create_table "ve_reservation_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "ve_reservation_id", unsigned: true
    t.integer "user_id",           unsigned: true
    t.index ["user_id"], name: "idx_ve_user_id", using: :btree
    t.index ["ve_reservation_id", "user_id"], name: "idx_ve_reservation_id_ve_user_id", unique: true, using: :btree
    t.index ["ve_reservation_id"], name: "idx_ve_reservation_id", using: :btree
  end

  create_table "ve_reservations", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at",                     default: -> { "CURRENT_TIMESTAMP" }
    t.string   "description"
    t.string   "auto_description"
    t.date     "begin"
    t.date     "end"
    t.text     "notes",            limit: 65535
    t.integer  "user_id",                                                                          unsigned: true
    t.boolean  "availability",                   default: false,                      null: false, unsigned: true
    t.index ["user_id"], name: "idx_user_id", using: :btree
  end

  create_table "ve_vehicle_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "ve_vehicle_id", unsigned: true
    t.integer "user_id",       unsigned: true
    t.index ["user_id", "ve_vehicle_id"], name: "idx_user_id_ve_vehicle_id", unique: true, using: :btree
    t.index ["user_id"], name: "idx_user_id", using: :btree
    t.index ["ve_vehicle_id"], name: "idx_ve_vehicle_id", using: :btree
  end

  create_table "ve_vehicles", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string  "vehicle_no"
    t.integer "year"
    t.string  "make"
    t.string  "model"
    t.string  "name"
    t.string  "assignment"
    t.string  "license"
    t.string  "account"
    t.boolean "active",     default: true, null: false, unsigned: true
    t.string  "color"
  end

end
