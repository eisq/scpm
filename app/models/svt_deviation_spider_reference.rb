class SvtDeviationSpiderReference < ActiveRecord::Base
	belongs_to :project
	has_many :svt_deviation_spider_settings
end
