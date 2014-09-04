class DropCiProjectsB < ActiveRecord::Migration
  def self.up
      drop_table :ci_projects
  end

  def self.down
    create_table :ci_projects do |t|
      t.integer :internal_id
      t.integer :external_id
      t.string :type
      t.string :stage
      t.string :category
      t.string :severity
      t.string :reproductibility
      t.text :summary
      t.text :description
      t.string :status
      t.datetime :submission_date
      t.string :reporter
      t.datetime :last_update
      t.string :last_update_person
      t.string :assigned_to
      t.string :priority
      t.string :visibility
      t.string :detection_version
      t.string :fixed_in_version
      t.string :status_precisions
      t.string :resolution_charge
      t.string :duplicated_id
      t.string :stages_to_reproduce
      t.string :additional_informations
      t.date :taking_into_account_date
      t.date :realisation_date
      t.string :realisation_author
      t.date :delivery_date
      t.date :reopening_date
      t.string :issue_origin
      t.string :detection_phase
      t.string :injection_phase
      t.string :real_test_of_detection
      t.string :theoretical_test_of_detection
      t.string :iteration
      t.string :lot
      t.string :entity
      t.string :team
      t.string :domain
      t.string :num_req_backlog
      t.string :origin
      t.string :output_type
      t.string :deliverables_list
      t.string :dev_team
      t.date :deployment
      t.string :airbus_responsible
      t.date :airbus_validation_date
      t.date :airbus_validation_date_objective
      t.date :airbus_validation_date_review
      t.string :ci_objective_20102011
      t.string :ci_objective_2012
      t.string :ci_objectives_2013
      t.string :deliverable_folder
      t.date :deployment_date
      t.date :deployment_date_objective
      t.date :specification_date
      t.date :kick_off_date
      t.date :launching_date_ddmmyyyy
      t.date :sqli_validation_date
      t.date :sqli_validation_date_objective
      t.date :specification_date_objective
      t.string :sqli_validation_responsible
      t.string :ci_objectives_2014
      t.string :linked_req
      t.string :quick_fix
      t.string :level_of_impact
      t.string :impacted_mnt_process
      t.string :path_backlog
      t.string :path_svn
      t.string :path_sfs_airbus
      t.string :item_type
      t.date :verification_date_objective
      t.date :verification_date
      t.string :request_origin
      t.string :issue_history
      t.integer :strategic, :default=>0
      t.string :report
      t.string :previous_report
      t.integer :sqli_validation_done, :default=> 0
      t.integer :airbus_validation_done, :default=> 0
      t.integer :deployment_done, :default=> 0
      t.integer :sqli_date_alert, :default=> 0
      t.integer :airbus_date_alert, :default=> 0
      t.integer :deployment_date_alert, :default=> 0
      t.timestamps
    end
  end
end
