class SvtDeviationMacroActivity < ActiveRecord::Base
  	has_many	:svt_deviation_macro_activity_deliverables
  	belongs_to  :svt_deviation_activities

  	def has_deliverable?(deliverable_id)
  		deliverable_count = svt_deviation_macro_activity_deliverables.count(:conditions => ["svt_deviation_deliverable_id = ?", deliverable_id])
  		return deliverable_count > 0
  	end
end
