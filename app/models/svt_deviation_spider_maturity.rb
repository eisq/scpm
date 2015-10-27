class SvtDeviationSpiderMaturity < ActiveRecord::Base
	belongs_to 	:svt_deviation_spider
	belongs_to	:svt_deviation_deliverable

	def get_planned
		planned = ""
		last_reference = SvtDeviationSpiderReference.find(:last, :conditions=>["project_id = ?", self.svt_deviation_spider.project_id])
		if last_reference
			SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ?", last_reference.id, self.svt_deviation_deliverable.name]).each do  |setting|
				if planned != "M&T"
					planned = whats_planned(setting)
				end
			end
		end

		return planned
	end

	def whats_planned(setting)
		planned = ""
		if setting.answer_1 == "Yes"
			planned = "M&T"
		elsif setting.answer_1 == "No" and setting.answer_3 == "Another template is used"
			planned = "Other"
		end

		return planned
	end
end