class CreateSvfDeviationSpiders < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_spiders do |t|
      t.integer :milestone_id
      t.boolean :impact_count, :default => false
      t.timestamps
      t.string :file_link
      t.integer :project_id
    end
  end

  def self.down
    drop_table :svf_deviation_spiders
  end
end