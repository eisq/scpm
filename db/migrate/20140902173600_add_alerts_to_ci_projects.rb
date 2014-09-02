class AddAlertsToCiProjects < ActiveRecord::Migration

	def self.up
		add_column :ci_projects, :sqli_date_alert, :integer, :default=> 0
		add_column :ci_projects, :airbus_date_alert, :integer, :default=> 0
		add_column :ci_projects, :deployment_date_alert, :integer, :default=> 0
	end

	def self.down
		remove_column :ci_projects, :sqli_date_alert
		remove_column :ci_projects, :airbus_date_alert
		remove_column :ci_projects, :deployment_date_alert
	end
end