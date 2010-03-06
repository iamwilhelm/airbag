class AddIsIndepToDatacolumns < ActiveRecord::Migration
  def self.up
    add_column :datacolumns, :is_indep, :boolean, :default => false
  end

  def self.down
    remove_column :datacolumns, :is_indep
  end
end
