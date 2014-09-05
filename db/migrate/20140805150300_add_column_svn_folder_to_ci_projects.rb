class AddColumnSvnFolderToCiProjects < ActiveRecord::Migration
  def self.up
  	add_column :ci_projects, :svn_delivery_folder, :text
  end

  def self.down
  	remove_column :ci_projects, :svn_delivery_folder
  end
end