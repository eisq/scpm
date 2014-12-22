class RenameIndexToMetaIndex < ActiveRecord::Migration
  def self.up
    rename_column :deviation_meta_activities, :index, :meta_index
  end

  def self.down
    rename_column :deviation_meta_activities, :meta_index, :index
  end
end