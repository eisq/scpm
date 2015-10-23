class SvtDeviationSpiderMaturity < ActiveRecord::Base
	belongs_to 	:svt_deviation_spider
	belongs_to	:svt_deviation_deliverable

	def get_planned
		planned = ""
		last_reference = SvtDeviationSpiderReference.find(:last, :conditions=>["project_id = ?", this.svt_deviation_spider.project_id])
		SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ?", last_reference.id, this.svt_deviation_deliverable.name]).each do  |setting|
			
		end

		return planned
	end
end