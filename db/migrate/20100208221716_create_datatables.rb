class CreateDatatables < ActiveRecord::Migration
  def self.up
    create_table :datatables do |t|
      t.integer  "datasource_id",                                      :null => false
      t.string   "descr"
      t.text     "notes"

      t.string   "table_heading",      :limit => 100,                  :null => false

      t.string   "col_heading",        :limit => 100,                  :null => false
      t.string   "col_labels_one",     :limit => 100,                  :null => false
      t.string   "col_labels_two",     :limit => 100,                  :null => false
      t.string   "col_labels_content",                                 :null => false

      t.string   "row_heading",        :limit => 100,                  :null => false
      t.string   "row_labels_one",     :limit => 100,                  :null => false
      t.string   "row_labels_two",     :limit => 100,                  :null => false
      t.string   "row_labels_content",                                 :null => false
      
      t.string   "data_one",           :limit => 100,                  :null => false
      t.string   "data_two",           :limit => 100,                  :null => false

      t.string   "other_dims"
      t.string   "default_dim",        :limit => 100, :default => "",  :null => false
      t.string   "is_numeric",         :limit => 1,   :default => "1", :null => false
      t.string   "units",                                              :null => false
      t.string   "multiplier",                        :default => "1"
      t.string   "converter"
      
      t.datetime "published_at"
      t.timestamps
    end
  end

  def self.down
    drop_table :datatables
  end
end
