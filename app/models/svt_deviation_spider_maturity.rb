class SvtDeviationSpiderMaturity < ActiveRecord::Base
	belongs_to 	:svt_deviation_spider
	belongs_to	:svt_deviation_deliverable

end