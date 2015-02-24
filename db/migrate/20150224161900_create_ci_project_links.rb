class CreateCiProjectLinks < ActiveRecord::Migration
  def self.up
    create_table :ci_project_links do |t|
      t.integer  :id
      t.integer  :first_ci_project_id
      t.integer  :second_ci_project_id
      t.string  :title
      t.timestamps
    end
  end

  def self.down
    drop_table :ci_project_links
  end
end
