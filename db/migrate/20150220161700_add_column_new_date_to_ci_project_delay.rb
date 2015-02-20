class AddColumnNewDateToCiProjectDelay < ActiveRecord::Migration
	def self.up
		add_column :ci_project_delays, :new_date, :date
	end

	def self.down
		remove_column :ci_projects_delays, :new_date
	end
end
