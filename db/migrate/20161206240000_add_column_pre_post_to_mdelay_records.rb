class AddColumnPrePostToMdelayRecords < ActiveRecord::Migration
  def self.up
  		add_column :mdelay_records, :pre_post_gm_five, :string
  end

  def self.down
  		remove_column :squads, :pre_post_gm_five
  end
end