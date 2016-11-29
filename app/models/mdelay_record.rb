class MdelayRecord < ActiveRecord::Base

	belongs_to  :mdelay_reason_one
	belongs_to  :mdelay_reason_two
	belongs_to  :phase
	belongs_to	:project
	belongs_to	:milestone

	def get_project_parent
		return self.project.project_name
	end

	def get_delay_days
		get_date_from_bdd_date(self.current_date) - get_date_from_bdd_date(self.initial_date)
	end

	def get_pre_post_gmfive
		value = nil
		self.pre_post_gm_five ? (value = self.pre_post_gm_five) : (value = self.project.pre_post_gm_five)
		return value
	end

	def get_caption_date
		return get_date_from_bdd_date(self.created_at)
	end

	def get_date_from_bdd_date(bdd_date)
	    date_split = bdd_date.to_s.split("-")
	    date = Date.new(date_split[0].to_i, date_split[1].to_i, date_split[2].to_i)

    	return date
	end

end