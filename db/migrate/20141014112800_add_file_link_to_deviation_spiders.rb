class AddFileLinkToDeviationSpiders < ActiveRecord::Migration

	def self.up
		add_column :deviation_spiders, :file_link, :string
	end

	def self.down
		remove_column :deviation_spiders, :file_link
	end
end
