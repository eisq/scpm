class AddColumnPlanningValidatedToCiProject < ActiveRecord::Migration
	def self.up
		add_column :ci_projects, :planning_validated, :boolean, :default => false
	end

	def self.down
		remove_column :ci_projects, :planning_validated
	end
end
