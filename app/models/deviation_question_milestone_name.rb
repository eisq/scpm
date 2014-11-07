class DeviationQuestionMilestoneName < ActiveRecord::Base
	belongs_to :deviation_question
	belongs_to :milestone_name
end
