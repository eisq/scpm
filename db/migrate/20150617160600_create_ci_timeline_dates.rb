class CreateCiTimelineDates < ActiveRecord::Migration
  def self.up
    create_table :ci_timeline_dates do |t|
      t.string :date_type
      t.date :date
      t.timestamps
    end
  end

  def self.down
    drop_table :ci_timeline_dates
  end
end