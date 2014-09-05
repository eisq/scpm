class AddSpecificToRequests < ActiveRecord::Migration
  def self.up
    add_column :requests, :specific, :string
  end

  def self.down
    remove_column :requests, :specific
  end
end

