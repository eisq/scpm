class MilestoneDelayRecord < ActiveRecord::Base
	has_many    :milestone_delay_reason_ones, :class_name=>"MilestoneDelayReasonOne", :foreign_key=>"reason_first_id"
	has_many    :milestone_delay_reason_twos, :class_name=>"MilestoneDelayReasonTwo", :foreign_key=>"reason_second_id"
	has_many    :milestone_delay_reason_threes, :class_name=>"MilestoneDelayReasonThree", :foreign_key=>"reason_third_id"
	belongs_to	:milestone
	belongs_to	:project
end