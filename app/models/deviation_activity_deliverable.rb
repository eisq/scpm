class DeviationActivityDeliverable < ActiveRecord::Base
	belongs_to :deviation_activity_id
	belongs_to :deviation_deliverable_id
end
