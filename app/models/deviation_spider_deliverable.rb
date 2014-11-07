class DeviationSpiderDeliverable < ActiveRecord::Base
	belongs_to 	:deviation_spider
	belongs_to 	:deviation_deliverable
	has_many    :deviation_spider_values
end
