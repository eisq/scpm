class SvtDeviationQuestionMilestoneName < ActiveRecord::Base
	belongs_to :svt_deviation_question
	belongs_to :milestone_name
end
