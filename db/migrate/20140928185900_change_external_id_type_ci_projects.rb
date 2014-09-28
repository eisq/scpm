class ChangeExternalIdTypeCiProjects < ActiveRecord::Migration
	def self.up
		change_column :ci_projects, :external_id, :text
	end

	def self.down
		change_column :ci_projects, :external_id, :integer
	end
end
