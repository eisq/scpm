class AddColumnsJustificationRetardsToCiProject < ActiveRecord::Migration
	def self.up
		add_column :ci_projects, :justification_airbus_retard, :string
		add_column :ci_projects, :justification_sqli_retard, :string
		add_column :ci_projects, :justification_deployment_retard, :string
	end

	def self.down
		remove_column :ci_projects, :justification_airbus_retard
		remove_column :ci_projects, :justification_sqli_retard
		remove_column :ci_projects, :justification_deployment_retard
	end
end
