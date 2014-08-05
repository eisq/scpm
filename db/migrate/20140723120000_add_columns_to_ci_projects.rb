class AddColumnsToCiProjects < ActiveRecord::Migration
  def self.up
  	add_column :ci_projects, :type, :text
    add_column :ci_projects, :reproducibility, :text
    add_column :ci_projects, :detection_version, :text
    add_column :ci_projects, :version_taken_into_account, :text
    add_column :ci_projects, :status_precision, :text
    add_column :ci_projects, :id_duplicate, :text
    add_column :ci_projects, :steps_to_reproduce, :text
    add_column :ci_projects, :reopening_date, :date
    add_column :ci_projects, :detection_phase, :text
    add_column :ci_projects, :injection_phase, :text
    add_column :ci_projects, :impact, :text
    add_column :ci_projects, :impact_time, :text
    add_column :ci_projects, :typology_of_change, :text
    add_column :ci_projects, :deliverables_updated, :text
    add_column :ci_projects, :iteration, :text
    add_column :ci_projects, :lot, :text
    add_column :ci_projects, :entity, :text
    add_column :ci_projects, :team, :text
    add_column :ci_projects, :domain, :text
    add_column :ci_projects, :backlog_request_id, :integer
    add_column :ci_projects, :ci_objectives_2010_2011, :text
    add_column :ci_projects, :ci_objectives_2012, :text
    add_column :ci_projects, :specification_date, :date
    add_column :ci_projects, :specification_date_objective, :date
    add_column :ci_projects, :ci_objectives_2014, :text
    add_column :ci_projects, :linked_req, :integer
    add_column :ci_projects, :quick_fix, :text
    add_column :ci_projects, :level_of_impact, :text
    add_column :ci_projects, :impacted_mnt_process, :text
    add_column :ci_projects, :path_backlog, :text
    add_column :ci_projects, :path_sfs_airbus, :text
    add_column :ci_projects, :item_type, :text
    add_column :ci_projects, :verification_date_objective, :date
    add_column :ci_projects, :verification_date, :date
    add_column :ci_projects, :request_origin, :text
  end

  def self.down
    remove_column :ci_projects, :type
    remove_column :ci_projects, :reproducibility
    remove_column :ci_projects, :detection_version
    remove_column :ci_projects, :version_taken_into_account
    remove_column :ci_projects, :status_precision
    remove_column :ci_projects, :id_duplicate
    remove_column :ci_projects, :steps_to_reproduce
    remove_column :ci_projects, :reopening_date
    remove_column :ci_projects, :detection_phase
    remove_column :ci_projects, :injection_phase
    remove_column :ci_projects, :impact
    remove_column :ci_projects, :impact_time
    remove_column :ci_projects, :typology_of_change
    remove_column :ci_projects, :deliverables_updated
    remove_column :ci_projects, :iteration
    remove_column :ci_projects, :lot
    remove_column :ci_projects, :entity
    remove_column :ci_projects, :team
    remove_column :ci_projects, :domain
    remove_column :ci_projects, :backlog_request_id
    remove_column :ci_projects, :ci_objectives_2010_2011
    remove_column :ci_projects, :ci_objectives_2012
    remove_column :ci_projects, :specification_date
    remove_column :ci_projects, :specification_date_objective
    remove_column :ci_projects, :ci_objectives_2014
    remove_column :ci_projects, :linked_req
    remove_column :ci_projects, :quick_fix
    remove_column :ci_projects, :level_of_impact
    remove_column :ci_projects, :impacted_mnt_process
    remove_column :ci_projects, :path_backlog
    remove_column :ci_projects, :path_sfs_airbus
    remove_column :ci_projects, :item_type
    remove_column :ci_projects, :verification_date_objective
    remove_column :ci_projects, :verification_date
    remove_column :ci_projects, :request_origin
  end
end