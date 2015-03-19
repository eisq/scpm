class CreateSvtDeviationActivityDeliverables < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_activity_deliverables do |t|
      t.integer  :svt_deviation_activity_id
      t.integer  :svt_deviation_deliverable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_activity_deliverables
  end
end