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

	def get_reason_one
		reason = ""
		if self.reason_first_id
			reason = self.milestone_delay_reason_one.reason_description
		end

		return reason
	end

	def get_reason_two
		reason = ""
		if self.reason_second_id
			reason = self.milestone_delay_reason_two.reason_description
		end

		return reason
	end

	def get_reason_three
		reason = ""
		if self.reason_third_id
			reason = self.milestone_delay_reason_three.reason_description
		end

		return reason
	end
end