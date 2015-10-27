class SvtDeviationDeliverable < ActiveRecord::Base
	has_many :svt_deviation_spider_consolidations
	has_many :svt_deviation_questions
	has_many :svt_deviation_spider_deliverables
  	has_many :svt_deviation_activity_deliverables
  	has_many :svt_deviation_spider_maturities
end
