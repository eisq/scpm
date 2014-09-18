class CreateDeviationSpiderDeliverables < ActiveRecord::Migration
  def self.up
    create_table :deviation_spider_deliverables do |t|
      t.integer :deviation_spider_id
      t.integer :deviation_deliverable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spider_deliverables
  end
end
