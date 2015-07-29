class CreateMilestoneDelayReasons < ActiveRecord::Migration
  def self.up
    create_table :milestone_delay_reasons do |t|
      t.string :reason_description
      t.integer :level_of_reason
      t.integer :reason_first_id_link
      t.integer :reason_second_id_link
      t.integer :reason_third_id_link
      t.timestamps
    end
  end

  def self.down
    drop_table :milestone_delay_reasons
  end
end