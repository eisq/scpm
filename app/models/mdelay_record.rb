class MdelayRecord < ActiveRecord::Base

	has_many    :mdelay_reason_ones, :class_name=>"MdelayReasonOne", :foreign_key=>"mdelay_reason_one_id"
	has_many    :mdelay_reason_twos, :class_name=>"MdelayReasonTwo", :foreign_key=>"mdelay_reason_two_id"
	has_many    :phase_of_identification, :class_name=>"Phase", :foreign_key=>"phase_of_identification_id"
	belongs_to	:workstream
	belongs_to	:workpackage
	belongs_to	:project
	belongs_to	:milestone

	def get_project_parent
		return self.project.project_name
	end

	def get_delay_days
		get_date_from_bdd_date(self.current_date) - get_date_from_bdd_date(self.initial_date)
	end

	def get_pre_post_gmfive
		return self.project.pre_post_gm_five
	end

	def get_date_from_bdd_date(bdd_date)
	    date_split = bdd_date.to_s.split("-")
	    date = Date.new(date_split[0].to_i, date_split[1].to_i, date_split[2].to_i)

    	return date
	end

end