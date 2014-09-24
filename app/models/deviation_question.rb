class DeviationQuestion < ActiveRecord::Base
	belongs_to :deviation_activity
	belongs_to :deviation_deliverable
	has_many :deviation_spider_values
end
