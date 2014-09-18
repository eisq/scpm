class DeviationSpiderReference < ActiveRecord::Base
	belongs_to :project
	has_many :deviation_spider_settings
end
