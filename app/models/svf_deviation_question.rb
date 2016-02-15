class SvfDeviationQuestion < ActiveRecord::Base
	belongs_to :svf_deviation_activity
	belongs_to :svf_deviation_deliverable
	has_many :svf_deviation_spider_values
	has_many :svf_deviation_question_milestone_names
	has_many :svf_deviation_question_lifecycles


  	def has_lifecycle?(lifecycle_id)
  		lifecycle_count = svf_deviation_question_lifecycles.count(:conditions => ["lifecycle_id = ?", lifecycle_id])
  		return lifecycle_count > 0
  	end

  	def has_milestone_name?(milestone_name_id)
  		milestone_name_count = svf_deviation_question_milestone_names.count(:conditions => ["milestone_name_id = ?", milestone_name_id])
  		return milestone_name_count > 0
  	end
end