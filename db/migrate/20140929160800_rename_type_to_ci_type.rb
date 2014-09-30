class RenameTypeToCiType < ActiveRecord::Migration
  def self.up
    rename_column :ci_projects, :type, :ci_type
  end

  def self.down
    rename_column :ci_projects, :ci_type, :type
  end
end