class CreateSvfDeviationMetaActivities < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_meta_activities do |t|
      t.string  :name
      t.boolean :is_active, :default => true
      t.timestamps
      t.integer :meta_index
    end
  end

  def self.down
    drop_table :svf_deviation_meta_activities
  end
end