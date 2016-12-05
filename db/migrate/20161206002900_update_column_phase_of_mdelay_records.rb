class UpdateColumnPhaseOfMdelayRecords < ActiveRecord::Migration
  def self.up
  		remove_column :mdelay_records, :phase_of_identification_id
  		add_column :mdelay_records, :phase_id, :integer
  end

  def self.down
  end
end