class AddProjectSiblingIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :sibling_id, :integer
  end

  def self.down
    remove_column :projects, :sibling_id
  end
end

