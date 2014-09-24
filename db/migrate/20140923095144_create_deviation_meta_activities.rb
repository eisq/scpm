class CreateDeviationMetaActivities < ActiveRecord::Migration
  def self.up
    create_table :deviation_meta_activities do |t|
      t.string  :name
      t.boolean :is_active, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spider_references
  end
end
