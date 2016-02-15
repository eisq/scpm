class SvfDeviationQuestionMilestoneName < ActiveRecord::Base
	belongs_to :svf_deviation_question
	belongs_to :milestone_name
end