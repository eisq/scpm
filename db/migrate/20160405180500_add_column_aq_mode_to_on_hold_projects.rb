class AddColumnAqModeToOnHoldProjects < ActiveRecord::Migration

	def self.up
		add_column :on_hold_projects, :aq_mode, :boolean
	end

	def self.down
		remove_column :on_hold_projects, :aq_mode
	end
end