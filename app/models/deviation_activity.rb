class DeviationActivity < ActiveRecord::Base
	has_many :deviation_spider_settings
	has_many :deviation_spider_consolidations
	has_many :deviation_questions
end
