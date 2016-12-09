class CreateMdelayRecords < ActiveRecord::Migration
  def self.up
    create_table :mdelay_records do |t|
      t.string :workstream
      t.integer :project_id
      t.integer :milestone_id
      t.string :pre_post_gm_five
      t.integer :phase_id
      t.boolean :deployment_impact
      t.string :initial_reason
      t.string :why_one
      t.string :why_two
      t.string :why_three
      t.string :why_four
      t.string :why_five
      t.string :analysed_reason
      t.integer :mdelay_reason_one_id
      t.integer :mdelay_reason_two_id
      t.string :consequence
      t.date :validation_date
      t.string :validated_by
      t.string :comments
      t.date :initial_date
      t.date :current_date
      t.timestamps
    end
  end

  def self.down
    drop_table :mdelay_records
  end
end