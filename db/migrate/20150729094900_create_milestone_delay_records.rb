class CreateMilestoneDelayRecords < ActiveRecord::Migration
  def self.up
    create_table :milestone_delay_records do |t|
      t.integer :milestone_id
      t.date :planned_date
      t.date :current_date
      t.integer :delay_days
      t.integer :reason_first_id
      t.integer :reason_second_id
      t.integer :reason_third_id
      t.string :reason_other
      t.timestamps
    end
  end

  def self.down
    drop_table :milestone_delay_records
  end
end