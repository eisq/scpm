class SvfDeviationDeliverable < ActiveRecord::Base
	has_many :svf_deviation_spider_consolidations
	has_many :svf_deviation_questions
	has_many :svf_deviation_spider_deliverables
  	has_many :svf_deviation_activity_deliverables
  	has_many :svf_deviation_spider_maturities
end