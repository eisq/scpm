class SvtDeviationActivity < ActiveRecord::Base
	has_many 	:svt_deviation_spider_consolidations
	has_many 	:svt_deviation_questions
  	has_many	:svt_deviation_activity_deliverables
  	has_many	:svt_deviation_macro_activities
  	belongs_to  :svt_deviation_meta_activity


  	def has_deliverable?(deliverable_id)
  		deliverable_count = svt_deviation_activity_deliverables.count(:conditions => ["svt_deviation_deliverable_id = ?", deliverable_id])
  		return deliverable_count > 0
  	end
end
