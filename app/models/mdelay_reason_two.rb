class MdelayReasonTwo < ActiveRecord::Base
	has_many	:mdelay_record
	belongs_to	:mdelay_reason_one

end