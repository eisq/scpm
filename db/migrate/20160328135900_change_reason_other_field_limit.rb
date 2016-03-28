class ChangeReasonOtherFieldLimit < ActiveRecord::Migration
	def self.up
		change_column :milestone_delay_records, :reason_other, :text, :limit => nil
	end

	def self.down
		change_column :milestone_delay_records, :reason_other, :string
	end
end