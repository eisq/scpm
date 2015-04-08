class CreateSvtDeviationMacroActivityDeliverableFlights < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_macro_activity_deliverable_flights do |t|
      t.string :svt_deviation_macro_activity_name
      t.string :svt_deviation_deliverable_name
      t.string :svt_deviation_activity_name
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
    drop_table :svt_deviation_macro_activity_deliverable_flights
  end
end