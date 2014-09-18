class DeviationDeliverable < ActiveRecord::Base
	has_many :deviation_spider_settings
	has_many :deviation_spider_consolidations
	has_many :deviation_questions
	has_many :deviation_spider_deliverables
	belongs_to :milestone_name
	belongs_to :lifecycle


end
