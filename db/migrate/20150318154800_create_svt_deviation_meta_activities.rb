class CreateSvtDeviationMetaActivities < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_meta_activities do |t|
      t.string  :name
      t.boolean :is_active, :default => true
      t.timestamps
      t.integer :meta_index
    end
  end

  def self.down
    drop_table :svt_deviation_meta_activities
  end
end