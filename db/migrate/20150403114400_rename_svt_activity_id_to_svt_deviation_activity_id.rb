class RenameSvtActivityIdToSvtDeviationActivityId < ActiveRecord::Migration
  def self.up
    rename_column :svt_deviation_macro_activities, :svt_activity_id, :svt_deviation_activity_id
  end

  def self.down
    rename_column :svt_deviation_macro_activities, :svt_deviation_activity_id, :svt_activity_id
  end
end