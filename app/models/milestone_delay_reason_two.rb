class MilestoneDelayReasonTwo < ActiveRecord::Base
	belongs_to	:milestone_delay_record, :class_name=>"MilestoneDelayRecord", :foreign_key=>"reason_second_id"
end