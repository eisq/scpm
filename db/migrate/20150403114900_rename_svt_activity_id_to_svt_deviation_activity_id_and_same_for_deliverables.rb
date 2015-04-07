class RenameSvtActivityIdToSvtDeviationActivityIdAndSameForDeliverables < ActiveRecord::Migration
  def self.up
    rename_column :svt_deviation_macro_activity_deliverables, :svt_activity_id, :svt_deviation_activity_id
    rename_column :svt_deviation_macro_activity_deliverables, :svt_deliverable_id, :svt_deviation_deliverable_id
  end

  def self.down
    rename_column :svt_deviation_macro_activity_deliverables, :svt_deviation_activity_id, :svt_activity_id
    rename_column :svt_deviation_macro_activity_deliverables, :svt_deviation_deliverable_id, :svt_deliverable_id
  end
end