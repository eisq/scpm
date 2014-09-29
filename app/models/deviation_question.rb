class DeviationQuestion < ActiveRecord::Base
	belongs_to :deviation_activity
	belongs_to :deviation_deliverable
	has_many :deviation_spider_values
	has_many :deviation_question_milestone_names
	has_many :deviation_question_lifecyles
end
