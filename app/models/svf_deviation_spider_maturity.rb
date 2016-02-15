class SvfDeviationSpiderMaturity < ActiveRecord::Base
	belongs_to 	:svf_deviation_spider
	belongs_to	:svf_deviation_deliverable

	def get_planned
		planned = ""
		last_reference = SvfDeviationSpiderReference.find(:last, :conditions=>["project_id = ?", self.svf_deviation_spider.project_id])
		if last_reference
			SvfDeviationSpiderSetting.find(:all, :conditions=>["svf_deviation_spider_reference_id = ? and deliverable_name = ?", last_reference.id, self.svf_deviation_deliverable.name]).each do  |setting|
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