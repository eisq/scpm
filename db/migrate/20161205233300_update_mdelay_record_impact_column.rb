class UpdateMdelayRecordImpactColumn < ActiveRecord::Migration
	def self.up
	  	change_column :mdelay_records, :deployment_impact, :string
	end
	def self.down
    	change_column :mdelay_records, :deployment_impact, :boolean
  	end
end