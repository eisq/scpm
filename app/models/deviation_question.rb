class DeviationQuestion < ActiveRecord::Base
	has_many :deviation_activities
	has_many :deviation_deliverables
	has_many :deviation_spider_values
end
