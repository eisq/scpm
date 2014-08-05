class AddColumnReportingToCiProjects < ActiveRecord::Migration
  def self.up
  	add_column :ci_projects, :report, :text
  	add_column :ci_projects, :previous_report, :text
  end

  def self.down
  	remove_column :ci_projects, :report
  	remove_column :ci_projects, :previous_report
  end
end