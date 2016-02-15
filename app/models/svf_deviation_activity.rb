class SvfDeviationActivity < ActiveRecord::Base
	has_many 	:svf_deviation_spider_consolidations
	has_many 	:svf_deviation_questions
  	has_many	:svf_deviation_activity_deliverables
  	has_many	:svf_deviation_macro_activities
  	belongs_to  :svf_deviation_meta_activity


  	def has_deliverable?(deliverable_id)
  		deliverable_count = svf_deviation_activity_deliverables.count(:conditions => ["svf_deviation_deliverable_id = ?", deliverable_id])
  		return deliverable_count > 0
  	end
end
