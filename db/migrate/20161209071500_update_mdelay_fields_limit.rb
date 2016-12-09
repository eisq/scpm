class UpdateMdelayFieldsLimit < ActiveRecord::Migration
	def self.up
		change_column :mdelay_records, :initial_reason, :text, :limit => nil
		change_column :mdelay_records, :why_one, :text, :limit => nil
		change_column :mdelay_records, :why_two, :text, :limit => nil
		change_column :mdelay_records, :why_three, :text, :limit => nil
		change_column :mdelay_records, :why_four, :text, :limit => nil
		change_column :mdelay_records, :why_five, :text, :limit => nil
		change_column :mdelay_records, :analysed_reason, :text, :limit => nil
		change_column :mdelay_records, :consequence, :text, :limit => nil
		change_column :mdelay_records, :validated_by, :text, :limit => nil
		change_column :mdelay_records, :comments, :text, :limit => nil
	end
	def self.down
  	end
end