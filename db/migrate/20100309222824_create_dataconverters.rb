class CreateDataconverters < ActiveRecord::Migration
  def self.up
    create_table :dataconverters do |t|
      t.integer :datacolumn_id, :null => false
      t.string :expression, :default => ""
      t.string :replacement, :default => ""
      t.integer :position, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dataconverters
  end
end
