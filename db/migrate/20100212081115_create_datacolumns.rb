class CreateDatacolumns < ActiveRecord::Migration
  def self.up
    create_table :datacolumns do |t|
      t.integer :datatable_id, :null => false
      t.string :xpath, :null => false
      t.integer :length
      t.timestamps
    end
  end

  def self.down
    drop_table :datacolumns
  end
end
