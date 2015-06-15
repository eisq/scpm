class AddColumnOldDateToCiProjectDelay < ActiveRecord::Migration
	def self.up
		add_column :ci_project_delays, :old_date, :date
	end

	def self.down
		remove_column :ci_project_delays, :old_date
	end
end
