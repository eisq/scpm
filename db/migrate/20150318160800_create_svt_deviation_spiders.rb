class CreateSvtDeviationSpiders < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_spiders do |t|
      t.integer :milestone_id
      t.boolean :impact_count, :default => false
      t.timestamps
      t.string :file_link
    end
  end

  def self.down
    drop_table :svt_deviation_spiders
  end
end