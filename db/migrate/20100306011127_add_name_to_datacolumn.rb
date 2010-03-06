class AddNameToDatacolumn < ActiveRecord::Migration
  def self.up
    add_column :datacolumns, :name, :string
  end

  def self.down
    remove_column :datacolumns, :name
  end
end
