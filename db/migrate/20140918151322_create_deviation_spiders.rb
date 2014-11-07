class CreateDeviationSpiders < ActiveRecord::Migration
  def self.up
    create_table :deviation_spiders do |t|
      t.integer :milestone_id
      t.boolean :impact_count, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spiders
  end
end
