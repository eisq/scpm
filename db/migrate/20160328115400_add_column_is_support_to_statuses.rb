class AddColumnIsSupportToStatuses < ActiveRecord::Migration

	def self.up
		add_column :statuses, :is_support, :boolean
	end

	def self.down
		remove_column :statuses, :is_support
	end
end