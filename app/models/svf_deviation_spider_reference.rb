class SvfDeviationSpiderReference < ActiveRecord::Base
	belongs_to :project
	has_many :svf_deviation_spider_settings
end