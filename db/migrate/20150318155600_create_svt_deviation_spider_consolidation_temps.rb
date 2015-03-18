class CreateSvtDeviationSpiderConsolidationTemps < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_spider_consolidation_temps do |t|
      t.integer  :id
      t.integer  :deviation_spider_id
      t.integer  :deviation_deliverable_id
      t.integer  :deviation_activity_id
      t.string   :score
      t.string   :justification, :limit => 1000
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_spider_consolidation_temps
  end
end