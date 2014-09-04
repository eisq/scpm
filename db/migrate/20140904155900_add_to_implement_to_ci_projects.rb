class AddToImplementToCiProjects < ActiveRecord::Migration

	def self.up
		add_column :ci_projects, :to_implement, :integer
	end

	def self.down
		remove_column :ci_projects, :to_implement
	end
end