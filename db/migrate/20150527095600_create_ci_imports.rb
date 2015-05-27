class CreateCiImports < ActiveRecord::Migration
  def self.up
    create_table :ci_imports do |t|
      t.string :import_type
      t.string :import_author
      t.timestamps
    end
  end

  def self.down
    drop_table :ci_imports
  end
end