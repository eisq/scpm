class CreateMilestoneDelayReasonThrees < ActiveRecord::Migration
  def self.up
    create_table :milestone_delay_reason_threes do |t|
      t.string :reason_description
      t.integer :reason_two_id
      t.boolean :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :milestone_delay_reason_threes
  end
end