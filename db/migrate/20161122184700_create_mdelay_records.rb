class CreateMdelayRecords < ActiveRecord::Migration
  def self.up
    create_table :mdelay_records do |t|
      t.string :workstream
      t.integer :project_id
      t.integer :milestone_id
      t.string :pre_post_gm_five
      t.integer :phase_id
      t.boolean :deployment_impact
      t.string :initial_reason, :limit => nil
      t.string :why_one, :limit => nil
      t.string :why_two, :limit => nil
      t.string :why_three, :limit => nil
      t.string :why_four, :limit => nil
      t.string :why_five, :limit => nil
      t.string :analysed_reason, :limit => nil
      t.integer :mdelay_reason_one_id
      t.integer :mdelay_reason_two_id
      t.string :consequence
      t.date :validation_date
      t.string :validated_by, :limit => nil
      t.string :comments, :limit => nil
      t.date :initial_date
      t.date :current_date
      t.timestamps
    end
  end

  def self.down
    drop_table :mdelay_records
  end
end