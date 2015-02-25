class AddColumnNewObjectivesToCiProject < ActiveRecord::Migration
	def self.up
		add_column :ci_projects, :ci_objectives_2015, :string
	end

	def self.down
		remove_column :ci_projects, :ci_objectives_2015
	end
end
