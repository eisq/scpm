class AddColumnIsOnHoldToProjects < ActiveRecord::Migration

	def self.up
		add_column :projects, :is_on_hold, :boolean, :default => false
	end

	def self.down
		remove_column :projects, :is_on_hold
	end
end