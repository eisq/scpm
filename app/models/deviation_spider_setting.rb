class DeviationSpiderSetting < ActiveRecord::Base
	belongs_to :deviation_spider_reference
	belongs_to :deviation_activity
	belongs_to :deviation_deliverable
end
