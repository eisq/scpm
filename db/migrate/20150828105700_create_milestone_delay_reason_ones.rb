class CreateMilestoneDelayReasonOnes < ActiveRecord::Migration
  def self.up
    create_table :milestone_delay_reason_ones do |t|
      t.string :reason_description
      t.boolean :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :milestone_delay_reason_ones
  end
end