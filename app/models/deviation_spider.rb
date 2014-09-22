class DeviationSpider < ActiveRecord::Base
  	has_many    :deviation_spider_consolidations
  	has_many    :deviation_spider_deliverables
  	has_many	:deviation_spider_activity_values
  	has_many	:deviation_spider_deliverable_values
	belongs_to 	:milestone
end
