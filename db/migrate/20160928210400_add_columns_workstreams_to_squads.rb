class AddColumnsWorkstreamsToSquads < ActiveRecord::Migration
  def self.up
  		add_column :squads, :workstream1, :string
  		add_column :squads, :workstream2, :string
  		add_column :squads, :workstream3, :string
  end

  def self.down
  		remove_column :squads, :workstream1
  		remove_column :squads, :workstream2
  		remove_column :squads, :workstream3
  end
end