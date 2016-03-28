class PersonSquad < ActiveRecord::Base
	has_many   :persons
	has_many   :squads
end