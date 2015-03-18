class CreateSvtDeviationActivities < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_activities do |t|
      t.string  :name
      t.boolean :is_active, :default => true
      t.integer :deviation_meta_activity_id
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_activities
  end
end