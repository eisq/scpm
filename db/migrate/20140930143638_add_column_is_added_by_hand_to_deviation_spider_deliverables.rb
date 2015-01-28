class AddColumnIsAddedByHandToDeviationSpiderDeliverables < ActiveRecord::Migration

	def self.up
		add_column :deviation_spider_deliverables, :is_added_by_hand, :boolean, :default => false
	end

	def self.down
		remove_column :deviation_spider_deliverables, :is_added_by_hand
	end
end
