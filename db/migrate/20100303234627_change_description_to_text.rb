class ChangeDescriptionToText < ActiveRecord::Migration
  def self.up
    change_column :datatables, :description, :string, :limit => 1024
  end

  def self.down
    change_column :datatables, :description, :string
  end
end
