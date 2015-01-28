class AddMultipleCreationToMilestoneNames < ActiveRecord::Migration
  def self.up
    add_column :milestone_names, :multiple_creation, :boolean, :default => false
  end

  def self.down
    remove_column :milestone_names, :multiple_creation
  end
end

