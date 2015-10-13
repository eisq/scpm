class MilestoneDelayRecord < ActiveRecord::Base
	has_many    :milestone_delay_reason_ones, :class_name=>"MilestoneDelayReasonOne", :foreign_key=>"reason_first_id"
	has_many    :milestone_delay_reason_twos, :class_name=>"MilestoneDelayReasonTwo", :foreign_key=>"reason_second_id"
	has_many    :milestone_delay_reason_threes, :class_name=>"MilestoneDelayReasonThree", :foreign_key=>"reason_third_id"
	belongs_to	:milestone
	belongs_to	:project

	def get_dws

		return self.project.workstream
	end

	def get_parent

		return self.project.project_name
	end

	def get_milestone_name
		name = ""
		if self.milestone
			name = self.milestone.name
		end
		return name
	end

	def get_reason_one
		reason = ""
		if self.reason_first_id
			reason_one = MilestoneDelayReasonOne.find(:first, :conditions=>["id=?", self.reason_first_id])
			if reason_one
				reason = reason_one.reason_description
			end
		end

		return reason
	end

	def get_reason_two
		reason = ""
		if self.reason_second_id
			reason_two = MilestoneDelayReasonTwo.find(:first, :conditions=>["id=?", self.reason_second_id])
			if reason_two
				reason = reason_two.reason_description
			end
		end

		return reason
	end

	def get_reason_three
		reason = ""
		if self.reason_third_id
			reason_three = MilestoneDelayReasonThree.find(:first, :conditions=>["id=?", self.reason_third_id])
			if reason_three
				reason = reason_three.reason_description
			end
		end

		return reason
	end

	def get_delay_days
		get_date_from_bdd_date(self.current_date) - get_date_from_bdd_date(self.planned_date)
	end

	def get_date_from_bdd_date(bdd_date)
    date_split = bdd_date.to_s.split("-")
    date = Date.new(date_split[0].to_i, date_split[1].to_i, date_split[2].to_i)

    return date
  end
end