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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130301093247) do

  create_table "admin_users", :id => false, :force => true do |t|
    t.string   "username"
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customers", :id => false, :force => true do |t|
    t.string   "debtor_code"
    t.string   "customer_name"
    t.string   "customer_org"
    t.string   "street1"
    t.string   "street2"
    t.string   "street3"
    t.string   "customer_city"
    t.string   "customer_province"
    t.string   "customer_postal"
    t.string   "customer_country"
    t.string   "customer_tel"
    t.string   "customer_fax"
    t.string   "customer_email"
    t.string   "customer_pass"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "domains", :id => false, :force => true do |t|
    t.string   "debtor_code",                      :null => false
    t.string   "domain_name"
    t.string   "ns_hostname1"
    t.string   "ns1_ipv4_addr"
    t.string   "ns1_ipv6_addr"
    t.string   "ns_hostname2"
    t.string   "ns2_ipv4_addr"
    t.string   "ns2_ipv6_addr"
    t.string   "domain_secret"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "deleted",       :default => false
    t.datetime "expiry_date"
    t.boolean  "autorenew",     :default => false
    t.boolean  "transfer_away", :default => false
  end

  create_table "events", :force => true do |t|
    t.string   "username"
    t.string   "action"
    t.text     "params"
    t.string   "cltrid"
    t.string   "svtrid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hosts", :force => true do |t|
    t.string   "hostname"
    t.string   "ipv4_addr"
    t.string   "ipv6_addr"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "messages", :force => true do |t|
    t.text     "message"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "readby"
    t.boolean  "read",       :default => false
  end

  create_table "requested_domains", :force => true do |t|
    t.string   "reqdomain"
    t.boolean  "is_transferred", :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "debtor_code"
    t.string   "status"
    t.datetime "issue"
    t.datetime "vote"
  end

end
