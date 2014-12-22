class AddColumnNotDoneToDeviationSpiderDeliverables < ActiveRecord::Migration

	def self.up
		add_column :deviation_spider_deliverables, :not_done, :boolean, :default => false
	end

	def self.down
		remove_column :deviation_spider_deliverables, :not_done
	end
end
