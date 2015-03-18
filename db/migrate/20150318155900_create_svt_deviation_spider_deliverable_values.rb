class CreateSvtDeviationSpiderDeliverableValues < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_spider_deliverable_values do |t|
      t.integer :deviation_spider_id
      t.integer :deviation_deliverable_id
      t.integer :yes_counter
      t.integer :no_counter
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_spider_deliverable_values
  end
end