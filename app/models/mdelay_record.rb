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

	def get_pre_post_gm_five
		value = nil
		if self.pre_post_gm_five and self.pre_post_gm_five != ""
			value = self.pre_post_gm_five
		else
			value = self.project.pre_post_gm_five
		end

		return value
	end

	def get_pre_post_gm_five_excel
		value = ""

		if self.pre_post_gm_five and self.pre_post_gm_five != ""
			if self.project.lifecycle_object and (self.project.lifecycle_object.name == "Full GPP" or self.project.lifecycle_object.name == "Agile" or self.project.lifecycle_object.name == "Waterfall")
				if self.pre_post_gm_five == "Pre-M5G5"
					value = "Pre-M5"
				elsif self.pre_post_gm_five == "Post-M5G5"
					value = "Post-M5"
				end
			elsif self.project.lifecycle_object and (self.project.lifecycle_object.name == "LBIP+" or self.project.lifecycle_object.name == "Suite")
				if self.pre_post_gm_five == "Pre-M5G5"
					value = "Pre-G5"
				elsif self.pre_post_gm_five == "Post-M5G5"
					value = "Post-G5"
				end
			end
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