class DeviationActivityDeliverable < ActiveRecord::Base
	belongs_to :deviation_activity
	belongs_to :deviation_deliverable
end
