class CreateSvfDeviationSpiderMaturities < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_spider_maturities do |t|
      t.integer :svf_deviation_spider_id
      t.integer :svf_deviation_deliverable_id
      t.string :planned
      t.string :achieved
      t.string :comment
      t.boolean :is_consolidated, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_spider_maturities
  end
end