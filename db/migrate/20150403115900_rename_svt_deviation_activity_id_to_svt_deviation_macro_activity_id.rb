class RenameSvtDeviationActivityIdToSvtDeviationMacroActivityId < ActiveRecord::Migration
  def self.up
    rename_column :svt_deviation_macro_activity_deliverables, :svt_deviation_activity_id, :svt_deviation_macro_activity_id
  end

  def self.down
    rename_column :svt_deviation_macro_activity_deliverables, :svt_deviation_macro_activity_id, :svt_deviation_activity_id
  end
end