class AddPhasesToCiProjects < ActiveRecord::Migration

	def self.up
		add_column :ci_projects, :current_phase, :text
		add_column :ci_projects, :next_phase, :text
	end

	def self.down
		remove_column :ci_projects, :current_phase
		remove_column :ci_projects, :next_phase
	end
end