class DeviationDeliverable < ActiveRecord::Base
	has_many :deviation_spider_consolidations
	has_many :deviation_questions
	has_many :deviation_spider_deliverables
  	has_many :deviation_activity_deliverables
end
