class ChangeColumnReportingSquads < ActiveRecord::Migration
	def self.up
		change_column :squads, :reporting, :text, :limit => nil
	end

	def self.down
		change_column :squads, :reporting, :string
	end
end