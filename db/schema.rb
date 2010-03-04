# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100304010357) do

  create_table "datacolumns", :force => true do |t|
    t.integer  "datatable_id", :null => false
    t.string   "xpath",        :null => false
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",     :null => false
  end

  create_table "datasources", :force => true do |t|
    t.string   "title",                           :default => "Untitled Datasource"
    t.string   "url",             :limit => 2048,                                    :null => false
    t.string   "type",                            :default => "TextHtml",            :null => false
    t.datetime "last_crawled_at"
    t.datetime "last_changed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "datatables", :force => true do |t|
    t.integer  "datasource_id",                                              :null => false
    t.string   "description",   :limit => 1024
    t.text     "notes"
    t.string   "name"
    t.string   "table_dim"
    t.string   "default_dim",                   :default => ""
    t.boolean  "is_numeric",                    :default => true
    t.string   "units"
    t.integer  "multiplier",                    :default => 1
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xpath",                                                      :null => false
    t.text     "datarows"
    t.string   "license",       :limit => 50,   :default => "public domain"
  end

end
