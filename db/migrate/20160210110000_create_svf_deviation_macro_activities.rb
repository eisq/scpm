class CreateSvfDeviationMacroActivities < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_macro_activities do |t|
      t.integer :svf_deviation_activity_id
      t.string :name
      t.boolean :is_active, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_macro_activities
  end
end