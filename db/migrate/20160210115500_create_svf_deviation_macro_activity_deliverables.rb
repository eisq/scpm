class CreateSvfDeviationMacroActivityDeliverables < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_macro_activity_deliverables do |t|
      t.integer :svf_deviation_macro_activity_id
      t.integer :svf_deviation_deliverable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_macro_activity_deliverables
  end
end