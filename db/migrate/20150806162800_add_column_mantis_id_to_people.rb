class AddColumnMantisIdToPeople < ActiveRecord::Migration
	def self.up
		add_column :people, :mantis_id, :int
	end

	def self.down
		remove_column :people, :mantis_id
	end
end