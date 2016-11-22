class MdelayReasonTwo < ActiveRecord::Base
	belongs_to	:mdelay_record
	belongs_to	:mdelay_reason_one
end