class AddMacroActivityNameToSvtDeviationSpiderSettings < ActiveRecord::Migration

	def self.up
		add_column :svt_deviation_spider_settings, :macro_activity_name, :string
	end

	def self.down
		remove_column :svt_deviation_spider_settings, :macro_activity_name
	end
end