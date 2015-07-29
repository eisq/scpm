class MilestoneDelayRecord < ActiveRecord::Base
	has_many    :milestone_delay_reasons
	belongs_to	:milestones
end