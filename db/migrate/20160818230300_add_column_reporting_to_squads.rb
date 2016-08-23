class AddColumnReportingToSquads < ActiveRecord::Migration
  def self.up
  		add_column :squads, :reporting, :string
  end

  def self.down
  		remove_column :squads, :reporting
  end
end