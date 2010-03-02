class Datarows < ActiveRecord::Migration
  def self.up
    add_column :datatables, :datarows, :text
  end

  def self.down
    remove_column :datatables, :datarows
  end
end
