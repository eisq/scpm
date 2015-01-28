class ChangeReportTypeCiProjects < ActiveRecord::Migration
	def self.up
		change_column :ci_projects, :report, :text, :limit => nil
	end

	def self.down
		change_column :ci_projects, :report, :string
	end
end
