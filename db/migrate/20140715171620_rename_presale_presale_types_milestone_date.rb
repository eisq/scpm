class RenamePresalePresaleTypesMilestoneDate < ActiveRecord::Migration
	def self.up
		change_column :presale_presale_types, :milestone_date, :date
		rename_column :presale_presale_types, :milestone_date, :first_meeting_date   
	end

	def self.down
		rename_column :presale_presale_types, :first_meeting_date, :milestone_date 
		change_column :presale_presale_types, :milestone_date, :integer
	end
end

