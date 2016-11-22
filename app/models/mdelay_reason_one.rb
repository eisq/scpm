class MdelayReasonOne < ActiveRecord::Base
	belongs_to	:mdelay_record
	has_many :mdelay_reason_two
end