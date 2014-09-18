class CreateDeviationSpiderReferences < ActiveRecord::Migration
  def self.up
    create_table :deviation_spider_references do |t|
      t.integer :project_id
      t.integer :version_number
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spider_references
  end
end
