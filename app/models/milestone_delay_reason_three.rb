class MilestoneDelayReasonThree < ActiveRecord::Base
	belongs_to	:milestone_delay_record, :class_name=>"MilestoneDelayRecord", :foreign_key=>"reason_third_id"
end