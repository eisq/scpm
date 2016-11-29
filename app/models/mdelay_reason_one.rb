class MdelayReasonOne < ActiveRecord::Base
	has_many   :mdelay_record
	has_many   :mdelay_reason_two

	def get_reason_twos
		reason_twos = Array.new
		reason_twos = MdelayReasonTwo.find(:all, :conditions=>["mdelay_reason_one_id = ? and is_active = ?", self.id, true])

		return reason_twos
	end
end