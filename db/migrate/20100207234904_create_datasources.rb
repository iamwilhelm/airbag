class CreateDatasources < ActiveRecord::Migration
  def self.up
    create_table :datasources do |t|
      t.string   "title", :limit => 255, :default => "Untitled Datasource"
      t.string   "url", :limit => 2048, :null => false
      t.string   "type", :default => "text_html", :null => false
      t.datetime "last_crawled_at"
      t.datetime "last_changed_at"
      t.timestamps
    end
  end

  def self.down
    drop_table :datasources
  end
end
