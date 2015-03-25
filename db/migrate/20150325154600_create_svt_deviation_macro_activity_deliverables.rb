class CreateSvtDeviationMacroActivityDeliverables < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_macro_activity_deliverables do |t|
      t.integer :svt_activity_id
      t.integer :svt_deliverable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_macro_activity_deliverables
  end
end