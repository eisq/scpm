class MdelayRecord < ActiveRecord::Base

	belongs_to  :mdelay_reason_one
	belongs_to  :mdelay_reason_two
	belongs_to  :phase
	belongs_to	:project
	belongs_to	:milestone

	def get_reason_one_by_name(reason_name)
		value = nil

		mdelay = MdelayReasonOne.find(:first, :conditions=>["reason_description = ? and is_active = ?", reason_name, true])
		if mdelay
			value = mdelay.id
		end

		return value
	end

	def get_reason_two_by_name(reason_name)
		value = nil

		mdelay = MdelayReasonTwo.find(:first, :conditions=>["reason_description = ? and is_active = ?", reason_name, true])
		if mdelay
			value = mdelay.id
		end

		return value
	end

	def format_deployment_impact(impact)
		value = nil

		if impact == "YES"
			value = "Yes"
		elsif impact == "NO"
			value = "No"
		end

		return value
	end

	def get_phase_by_name(phase_name)
		value = nil

		value = Phase.find(:first, :conditions=>["name = ? and is_active = ?", phase_name, true])

		return value
	end

	def get_project_parent
		return self.project.project_name
	end

	def get_delay_days
		get_date_from_bdd_date(self.current_date) - get_date_from_bdd_date(self.initial_date)
	end

	def get_pre_post_gm_five
		value = nil
		if self.pre_post_gm_five and self.pre_post_gm_five != ""
			value = self.pre_post_gm_five
		else
			value = self.project.pre_post_gm_five
		end

		return value
	end

	def get_caption_date
		value = nil

		if self.created_at
			value = get_date_from_bdd_date(self.created_at).strftime("%d/%m/%Y")
		end

		return value
	end

	def get_initial_date
		value = nil

		if self.initial_date
			value = get_date_from_bdd_date(self.initial_date).strftime("%d/%m/%Y")
		end

		return value
	end

	def get_current_date
		value = nil

		if self.current_date
			value = get_date_from_bdd_date(self.current_date).strftime("%d/%m/%Y")
		end

		return value
	end

	def get_validation_date
		value = nil

		if self.validation_date
			value = get_date_from_bdd_date(self.validation_date).strftime("%d/%m/%Y")
		end

		return value
	end

	def get_date_from_bdd_date(bdd_date)
		if bdd_date and bdd_date != ""
		    date_split = bdd_date.to_s.split("-")
		    date = Date.new(date_split[0].to_i, date_split[1].to_i, date_split[2].to_i)
		end

    	return date
	end

end