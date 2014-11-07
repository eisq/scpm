class CreateDeviationSpiderConsolidationTemps < ActiveRecord::Migration
  def self.up
    create_table :deviation_spider_consolidation_temps do |t|
      t.integer  :id
      t.integer  :deviation_spider_id
      t.integer  :deviation_deliverable_id
      t.integer  :deviation_activity_id
      t.string   :score
      t.string   :justification
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spider_consolidation_temps
  end
end
