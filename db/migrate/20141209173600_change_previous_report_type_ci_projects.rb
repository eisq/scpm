class ChangePreviousReportTypeCiProjects < ActiveRecord::Migration
	def self.up
		change_column :ci_projects, :previous_report, :text, :limit => nil
	end

	def self.down
		change_column :ci_projects, :previous_report, :string
	end
end
