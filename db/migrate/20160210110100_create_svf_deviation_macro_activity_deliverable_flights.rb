class CreateSvfDeviationMacroActivityDeliverableFlights < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_macro_activity_deliverable_flights do |t|
      t.string :svf_deviation_macro_activity_name
      t.string :svf_deviation_deliverable_name
      t.string :svf_deviation_activity_name
      t.integer :project_id
      t.string :answer_1
      t.string :answer_2
      t.string :answer_3
      t.string :justification
      t.integer :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_macro_activity_deliverable_flights
  end
end