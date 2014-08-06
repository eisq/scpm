class AddColumnsDoneToCiProjects < ActiveRecord::Migration
  def self.up
  	add_column :ci_projects, :sqli_validation_done, :integer, :default=> 0
  	add_column :ci_projects, :airbus_validation_done, :integer, :default=> 0
  	add_column :ci_projects, :deployment_done, :integer, :default=> 0
  end

  def self.down
  	remove_column :ci_projects, :sqli_validation_done
  	remove_column :ci_projects, :airbus_validation_done
  	remove_column :ci_projects, :deployment_done
  end
end