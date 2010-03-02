class AddPositionToDatacolumns < ActiveRecord::Migration
  def self.up
    add_column :datacolumns, :position, :integer, :null => false
  end

  def self.down
    remove_column :datacolumns, :position
  end
end
