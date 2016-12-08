class UpdateConsequenceField < ActiveRecord::Migration
	def self.up
	  	change_column :mdelay_records, :consequence, :string, :limit => nil
	end
	def self.down
    	change_column :mdelay_records, :consequence, :string
  	end
end