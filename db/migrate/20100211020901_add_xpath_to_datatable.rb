class AddXpathToDatatable < ActiveRecord::Migration
  def self.up
    add_column :datatables, :xpath, :string, :null => false
  end

  def self.down
    remove_column :datatables, :xpath
  end
end
