# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160701095339) do

  create_table "actions", :force => true do |t|
    t.text     "action"
    t.integer  "person_id"
    t.integer  "project_id"
    t.date     "creation_date"
    t.date     "due_date"
    t.string   "progress",      :limit => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "result"
    t.integer  "private",                    :default => 0
    t.integer  "origin_id",                  :default => 0
  end

  create_table "amendments", :force => true do |t|
    t.integer  "project_id"
    t.string   "responsible"
    t.string   "milestone"
    t.text     "amendment"
    t.text     "action"
    t.date     "duedate"
    t.integer  "done",         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "closing_date"
    t.date     "done_date"
  end

  create_table "backgrounds", :force => true do |t|
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bandeaus", :force => true do |t|
    t.text     "text"
    t.integer  "person_id"
    t.datetime "last_display"
    t.integer  "nb_displays",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "capi_axes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "centers", :force => true do |t|
    t.string   "name"
    t.integer  "supervisor_id"
    t.integer  "workstreamleader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_message_reads", :force => true do |t|
    t.integer "chat_message_id"
    t.integer "person_id"
    t.integer "chat_session_id"
    t.integer "state",           :default => 0
  end

  create_table "chat_messages", :force => true do |t|
    t.integer  "chat_session_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.text     "msg"
  end

  create_table "chat_session_participants", :force => true do |t|
    t.integer "chat_session_id"
    t.integer "person_id"
  end

  create_table "chat_sessions", :force => true do |t|
    t.datetime "created_at"
    t.string   "title"
  end

  create_table "checklist_item_template_milestone_names", :force => true do |t|
    t.integer "checklist_item_template_id"
    t.integer "milestone_name_id"
  end

  create_table "checklist_item_template_workpackages", :force => true do |t|
    t.integer "checklist_item_template_id"
    t.integer "workpackage_id"
  end

  create_table "checklist_item_templates", :force => true do |t|
    t.integer  "requirement_id"
    t.integer  "parent_id"
    t.string   "ctype"
    t.integer  "is_transverse",  :default => 0
    t.string   "title"
    t.integer  "deployed",       :default => 0
    t.integer  "order",          :default => 0
    t.integer  "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "values"
    t.boolean  "is_qr_qwr",      :default => false
  end

  create_table "checklist_items", :force => true do |t|
    t.integer  "milestone_id"
    t.integer  "request_id"
    t.integer  "parent_id"
    t.integer  "template_id"
    t.integer  "hidden",       :default => 0
    t.integer  "status",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "answer"
    t.integer  "project_id"
  end

  add_index "checklist_items", ["parent_id"], :name => "IDX_CHECKLIST_ITEMS_PARENT_ID"
  add_index "checklist_items", ["template_id"], :name => "IDX_CHECKLIST_ITEMS_TEMPLATE_ID"

  create_table "ci_imports", :force => true do |t|
    t.string   "import_type"
    t.string   "import_author"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ci_project_delays", :force => true do |t|
    t.integer  "ci_project_id"
    t.string   "title"
    t.string   "justification"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "new_date"
    t.date     "old_date"
  end

  create_table "ci_project_links", :force => true do |t|
    t.integer  "first_ci_project_id"
    t.integer  "second_ci_project_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ci_projects", :force => true do |t|
    t.integer  "internal_id"
    t.text     "external_id"
    t.string   "ci_type"
    t.string   "stage"
    t.string   "category"
    t.string   "severity"
    t.string   "reproductibility"
    t.text     "summary"
    t.text     "description"
    t.string   "status"
    t.datetime "submission_date"
    t.string   "reporter"
    t.datetime "last_update"
    t.string   "last_update_person"
    t.string   "assigned_to"
    t.string   "priority"
    t.string   "visibility"
    t.string   "detection_version"
    t.string   "fixed_in_version"
    t.string   "status_precisions"
    t.string   "resolution_charge"
    t.string   "duplicated_id"
    t.string   "stages_to_reproduce"
    t.string   "additional_informations"
    t.date     "taking_into_account_date"
    t.date     "realisation_date"
    t.string   "realisation_author"
    t.date     "delivery_date"
    t.date     "reopening_date"
    t.string   "issue_origin"
    t.string   "detection_phase"
    t.string   "injection_phase"
    t.string   "real_test_of_detection"
    t.string   "theoretical_test_of_detection"
    t.string   "iteration"
    t.string   "lot"
    t.string   "entity"
    t.string   "team"
    t.string   "domain"
    t.string   "num_req_backlog"
    t.string   "origin"
    t.string   "output_type"
    t.string   "deliverables_list"
    t.string   "dev_team"
    t.date     "deployment"
    t.string   "airbus_responsible"
    t.date     "airbus_validation_date"
    t.date     "airbus_validation_date_objective"
    t.date     "airbus_validation_date_review"
    t.string   "ci_objective_20102011"
    t.string   "ci_objective_2012"
    t.string   "ci_objectives_2013"
    t.string   "deliverable_folder"
    t.date     "deployment_date"
    t.date     "deployment_date_objective"
    t.date     "specification_date"
    t.date     "kick_off_date"
    t.date     "launching_date_ddmmyyyy"
    t.date     "sqli_validation_date"
    t.date     "sqli_validation_date_objective"
    t.date     "specification_date_objective"
    t.string   "sqli_validation_responsible"
    t.string   "ci_objectives_2014"
    t.string   "linked_req"
    t.string   "quick_fix"
    t.string   "level_of_impact"
    t.string   "impacted_mnt_process"
    t.string   "path_backlog"
    t.string   "path_svn"
    t.string   "path_sfs_airbus"
    t.string   "item_type"
    t.date     "verification_date_objective"
    t.date     "verification_date"
    t.string   "request_origin"
    t.string   "issue_history"
    t.integer  "strategic",                        :default => 0
    t.text     "report"
    t.text     "previous_report"
    t.integer  "sqli_validation_done",             :default => 0
    t.integer  "airbus_validation_done",           :default => 0
    t.integer  "deployment_done",                  :default => 0
    t.integer  "sqli_date_alert",                  :default => 0
    t.integer  "airbus_date_alert",                :default => 0
    t.integer  "deployment_date_alert",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "to_implement"
    t.text     "current_phase"
    t.text     "next_phase"
    t.boolean  "planning_validated",               :default => false
    t.string   "justification_airbus_retard"
    t.string   "justification_sqli_retard"
    t.string   "justification_deployment_retard"
    t.string   "ci_objectives_2015"
    t.text     "airbus_commit_author"
    t.text     "sqli_commit_author"
    t.text     "deployment_commit_author"
  end

  create_table "ci_timeline_dates", :force => true do |t|
    t.string   "date_type"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wl_holidays_calendar_id"
  end

  create_table "cost_profiles", :force => true do |t|
    t.string   "name"
    t.integer  "cost"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counter_base_values", :force => true do |t|
    t.string   "complexity"
    t.string   "sdp_iteration"
    t.string   "workpackage"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counter_logs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "request_id"
    t.integer  "counter_value"
    t.datetime "import_date"
    t.boolean  "validity",      :default => false
  end

  create_table "deviation_activities", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",                  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "deviation_meta_activity_id"
  end

  create_table "deviation_activity_deliverables", :force => true do |t|
    t.integer  "deviation_activity_id"
    t.integer  "deviation_deliverable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_deliverables", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_meta_activities", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "meta_index"
  end

  create_table "deviation_question_lifecycles", :force => true do |t|
    t.integer  "deviation_question_id"
    t.integer  "lifecycle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_question_milestone_names", :force => true do |t|
    t.integer  "deviation_question_id"
    t.integer  "milestone_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_questions", :force => true do |t|
    t.integer  "deviation_deliverable_id"
    t.integer  "deviation_activity_id"
    t.text     "question_text"
    t.boolean  "is_active",                :default => true
    t.boolean  "answer_reference",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_spider_activity_values", :force => true do |t|
    t.integer  "deviation_spider_id"
    t.integer  "deviation_activity_id"
    t.integer  "yes_counter"
    t.integer  "no_counter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_spider_consolidation_temps", :force => true do |t|
    t.integer  "deviation_spider_id"
    t.integer  "deviation_deliverable_id"
    t.integer  "deviation_activity_id"
    t.integer  "score"
    t.string   "justification",            :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_spider_consolidations", :force => true do |t|
    t.integer  "deviation_spider_id"
    t.integer  "deviation_deliverable_id"
    t.integer  "deviation_activity_id"
    t.integer  "score"
    t.text     "justification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_spider_deliverable_values", :force => true do |t|
    t.integer  "deviation_spider_id"
    t.integer  "deviation_deliverable_id"
    t.integer  "yes_counter"
    t.integer  "no_counter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_spider_deliverables", :force => true do |t|
    t.integer  "deviation_spider_id"
    t.integer  "deviation_deliverable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "not_done",                 :default => false
    t.boolean  "is_added_by_hand",         :default => false
  end

  create_table "deviation_spider_references", :force => true do |t|
    t.integer  "project_id"
    t.integer  "version_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_spider_settings", :force => true do |t|
    t.integer  "deviation_spider_reference_id"
    t.string   "deliverable_name"
    t.string   "activity_name"
    t.string   "answer_1"
    t.string   "answer_2"
    t.string   "answer_3"
    t.text     "justification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_spider_values", :force => true do |t|
    t.integer  "deviation_spider_deliverable_id"
    t.integer  "deviation_question_id"
    t.boolean  "answer"
    t.boolean  "answer_reference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deviation_spiders", :force => true do |t|
    t.integer  "milestone_id"
    t.boolean  "impact_count", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_link"
    t.integer  "project_id"
  end

  create_table "generic_risk_questions", :force => true do |t|
    t.text     "question"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "milestone_name_id"
    t.integer  "capi_axis_id"
    t.integer  "deployed",          :default => 0
  end

  create_table "generic_risks", :force => true do |t|
    t.integer  "generic_risk_question_id"
    t.integer  "is_quality"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "context"
    t.text     "risk"
    t.text     "consequence"
    t.text     "actions"
  end

  add_index "generic_risks", ["generic_risk_question_id"], :name => "IDX_GENERIC_RISKS"

  create_table "history_counters", :force => true do |t|
    t.integer  "request_id"
    t.datetime "action_date"
    t.integer  "author_id"
    t.integer  "concerned_status_id"
    t.integer  "concerned_spider_id"
    t.integer  "stream_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "holidays_calendars", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iterations", :force => true do |t|
    t.string   "name"
    t.string   "project_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lesson_collect_actions", :force => true do |t|
    t.integer  "lesson_collect_file_id"
    t.string   "ref"
    t.date     "creation_date"
    t.string   "source"
    t.text     "title"
    t.text     "status"
    t.string   "actionne"
    t.date     "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "benefit"
    t.integer  "level_of_investment"
  end

  create_table "lesson_collect_assessments", :force => true do |t|
    t.integer  "lesson_collect_file_id"
    t.integer  "lesson_id"
    t.string   "milestone"
    t.string   "mt_detailed_desc"
    t.string   "quality_gates"
    t.string   "milestones_preparation"
    t.string   "project_setting_up"
    t.string   "lessons_learnt"
    t.string   "support_level"
    t.text     "mt_improvements"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lesson_collect_axes", :force => true do |t|
    t.string "name"
  end

  create_table "lesson_collect_file_analyzes", :force => true do |t|
    t.integer  "person_id"
    t.integer  "lesson_collect_file_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lesson_collect_file_downloads", :force => true do |t|
    t.integer  "user_id"
    t.integer  "lesson_collect_file_id"
    t.datetime "download_date"
  end

  create_table "lesson_collect_files", :force => true do |t|
    t.string   "pm"
    t.string   "qwr_sqr"
    t.string   "workstream"
    t.string   "suite_name"
    t.string   "project_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lesson_collect_template_type_id"
    t.integer  "request_id"
    t.string   "filename"
    t.string   "mt_qr"
    t.text     "comment"
    t.boolean  "is_archived",                     :default => false
  end

  create_table "lesson_collect_sub_axes", :force => true do |t|
    t.string  "name"
    t.integer "lesson_collect_axe_id"
  end

  create_table "lesson_collect_template_types", :force => true do |t|
    t.string "name"
  end

  create_table "lesson_collects", :force => true do |t|
    t.integer  "lesson_collect_file_id"
    t.string   "lesson_id"
    t.string   "milestone"
    t.string   "type_lesson"
    t.text     "topics"
    t.text     "cause"
    t.text     "improvement"
    t.string   "axes"
    t.string   "sub_axes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lesson_collect_axe_id"
    t.integer  "lesson_collect_sub_axe_id"
    t.string   "escalate_next_level"
    t.string   "project_name"
    t.boolean  "action_plan"
    t.boolean  "already_exist"
    t.string   "redundancy"
    t.boolean  "selected"
    t.string   "status"
    t.string   "raised_in_dws_plm"
  end

  create_table "lifecycle_milestones", :force => true do |t|
    t.integer  "lifecycle_id"
    t.integer  "milestone_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "index_order"
  end

  create_table "lifecycle_questions", :force => true do |t|
    t.integer  "lifecycle_id"
    t.integer  "pm_type_axe_id"
    t.string   "text"
    t.boolean  "validity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lifecycles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",  :default => true
  end

  create_table "line_tags", :force => true do |t|
    t.integer  "line_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logs", :force => true do |t|
    t.string   "controller"
    t.string   "action"
    t.string   "controller_action"
    t.string   "browser"
    t.string   "ip"
    t.string   "session_id"
    t.integer  "person_id"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestone_delay_reason_ones", :force => true do |t|
    t.string   "reason_description"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestone_delay_reason_threes", :force => true do |t|
    t.string   "reason_description"
    t.integer  "reason_two_id"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestone_delay_reason_twos", :force => true do |t|
    t.string   "reason_description"
    t.integer  "reason_one_id"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestone_delay_reasons", :force => true do |t|
    t.string   "reason_description"
    t.integer  "level_of_reason"
    t.integer  "reason_first_id_link"
    t.integer  "reason_second_id_link"
    t.integer  "reason_third_id_link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestone_delay_records", :force => true do |t|
    t.integer  "milestone_id"
    t.date     "planned_date"
    t.date     "current_date"
    t.integer  "delay_days"
    t.integer  "reason_first_id"
    t.integer  "reason_second_id"
    t.integer  "reason_third_id"
    t.text     "reason_other"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "project_id"
  end

  create_table "milestone_names", :force => true do |t|
    t.string  "title"
    t.boolean "count_in_spider_prev", :default => true
    t.boolean "is_active",            :default => true
    t.boolean "multiple_creation",    :default => false
  end

  create_table "milestones", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.date     "milestone_date"
    t.date     "actual_milestone_date"
    t.integer  "status"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "done",                     :default => 0
    t.integer  "checklist_not_applicable", :default => 0
    t.integer  "index_order"
    t.boolean  "is_virtual",               :default => false
    t.boolean  "to_export",                :default => false
    t.text     "current_quality_status"
  end

  add_index "milestones", ["project_id"], :name => "IDX_MILESTONES"

  create_table "monthly_task_people", :force => true do |t|
    t.integer  "monthly_task_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "monthly_task_types", :force => true do |t|
    t.string   "name"
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "monthly_tasks", :force => true do |t|
    t.string   "title"
    t.float    "load_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "monthly_task_type_id"
  end

  create_table "notes", :force => true do |t|
    t.text     "note"
    t.integer  "project_id"
    t.integer  "private",      :default => 1
    t.integer  "person_id"
    t.integer  "note_id",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "capi_axis_id", :default => -1
  end

  create_table "on_hold_projects", :force => true do |t|
    t.integer  "project_id"
    t.boolean  "on_hold"
    t.integer  "total",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "aq_mode"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rmt_user"
    t.integer  "is_supervisor",   :default => 0
    t.string   "login"
    t.string   "pwd"
    t.datetime "last_view"
    t.integer  "has_left",        :default => 0
    t.integer  "sdp_id",          :default => -1
    t.string   "trigram"
    t.integer  "is_transverse",   :default => 0
    t.integer  "is_cpdp",         :default => 0
    t.integer  "is_virtual",      :default => 0
    t.text     "settings"
    t.integer  "cost_profile_id"
    t.integer  "tbp_collab_id"
    t.integer  "mantis_id"
  end

  create_table "person_roles", :force => true do |t|
    t.integer  "person_id"
    t.integer  "role_id"
    t.datetime "created_at"
  end

  add_index "person_roles", ["person_id"], :name => "IDX_PERSON_ROLES_PERSON_ID"

  create_table "person_squads", :force => true do |t|
    t.integer  "person_id"
    t.integer  "squad_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plannings", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pm_type_axe_excels", :force => true do |t|
    t.integer  "axe_id"
    t.integer  "lifecycle_id"
    t.integer  "excel_position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pm_type_axes", :force => true do |t|
    t.integer  "pm_type_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pm_types", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "presale_comments", :force => true do |t|
    t.integer  "presale_presale_type_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "person_id"
  end

  create_table "presale_ignore_projects", :force => true do |t|
    t.integer  "project_id"
    t.integer  "presale_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "presale_presale_types", :force => true do |t|
    t.integer  "presale_id"
    t.integer  "presale_type_id"
    t.integer  "opportunity_number"
    t.date     "first_meeting_date"
    t.string   "status"
    t.string   "complexity"
    t.date     "buyside_launch_date"
    t.date     "buyside_accepted_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "milestone_name_id"
  end

  create_table "presale_types", :force => true do |t|
    t.text     "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "presales", :force => true do |t|
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_people", :id => false, :force => true do |t|
    t.integer  "project_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "brn"
    t.string   "workstream"
    t.integer  "project_id"
    t.integer  "last_status",          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supervisor_id"
    t.string   "coordinator"
    t.string   "pm"
    t.string   "bpl"
    t.string   "ispl"
    t.datetime "read_date"
    t.integer  "lifecycle",            :default => 0
    t.string   "pm_deputy"
    t.string   "ispm"
    t.integer  "lifecycle_id"
    t.integer  "qs_count",             :default => 0
    t.integer  "spider_count",         :default => 0
    t.boolean  "is_running",           :default => true
    t.integer  "qr_qwr_id"
    t.string   "dwr"
    t.boolean  "is_qr_qwr",            :default => false
    t.integer  "suite_tag_id"
    t.string   "project_code"
    t.integer  "sales_revenue",        :default => 0
    t.integer  "sibling_id"
    t.integer  "tbp_project_id"
    t.boolean  "deviation_spider",     :default => false
    t.boolean  "deviation_spider_svt", :default => false
    t.boolean  "deviation_spider_svf", :default => false
    t.boolean  "is_on_hold",           :default => false
  end

  add_index "projects", ["project_id"], :name => "IDX_PROJECTS_ON_PROJECT_ID"

  create_table "question_references", :force => true do |t|
    t.integer  "question_id"
    t.integer  "milestone_id"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "req_categories", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "public",     :default => 0
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "req_impacts", :force => true do |t|
    t.integer  "requirement_id"
    t.integer  "person_id"
    t.text     "impact"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "req_waves", :force => true do |t|
    t.string   "name"
    t.integer  "status",                          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "deployment_target_date"
    t.date     "deployment_target_date_revision"
  end

  create_table "requests", :force => true do |t|
    t.string   "request_id"
    t.string   "workstream"
    t.string   "status"
    t.string   "assigned_to"
    t.string   "resolution"
    t.string   "updated"
    t.string   "reporter"
    t.string   "view_status"
    t.string   "milestone"
    t.string   "priority"
    t.string   "summary"
    t.string   "date_submitted"
    t.string   "product_version"
    t.string   "severity"
    t.string   "platform"
    t.string   "work_package"
    t.string   "complexity"
    t.string   "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sdp"
    t.string   "pm"
    t.string   "milestone_date"
    t.string   "project_name"
    t.string   "actual_m_date"
    t.string   "end_date"
    t.integer  "project_id"
    t.date     "status_to_be_validated"
    t.date     "status_new"
    t.date     "status_feedback"
    t.date     "status_acknowledged"
    t.date     "status_assigned"
    t.date     "status_contre_visite"
    t.date     "status_performed"
    t.date     "status_cancelled"
    t.date     "status_closed"
    t.date     "total_csv_severity"
    t.date     "total_csv_category"
    t.string   "po"
    t.string   "contre_visite"
    t.string   "sdpiteration"
    t.string   "contre_visite_milestone"
    t.string   "request_type"
    t.integer  "stream_id"
    t.string   "is_stream",               :default => "No"
    t.string   "specific"
    t.string   "qr"
  end

  add_index "requests", ["project_id"], :name => "IDX_REQUESTS_ON_PROJECT_ID"
  add_index "requests", ["request_id"], :name => "index_requests_on_request_id"

  create_table "requirement_versions", :force => true do |t|
    t.integer  "requirement_id"
    t.integer  "version"
    t.integer  "req_category_id"
    t.string   "source_name"
    t.string   "short_name"
    t.text     "description"
    t.integer  "status"
    t.datetime "status_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "req_wave_id"
    t.integer  "linked_req_id"
    t.integer  "person_id"
    t.integer  "impact"
    t.date     "source_date"
    t.string   "source_identifier"
    t.integer  "priority"
    t.text     "long_description"
    t.text     "compliance_means"
    t.string   "is_covered"
    t.text     "cover_detail"
    t.date     "last_review"
  end

  add_index "requirement_versions", ["requirement_id"], :name => "index_requirement_versions_on_requirement_id"

  create_table "requirements", :force => true do |t|
    t.integer  "req_category_id"
    t.string   "source_name"
    t.string   "short_name"
    t.text     "description"
    t.integer  "status"
    t.datetime "status_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "req_wave_id",       :null => false
    t.integer  "linked_req_id"
    t.integer  "person_id"
    t.integer  "version"
    t.date     "source_date"
    t.string   "source_identifier"
    t.integer  "priority"
    t.integer  "impact"
    t.text     "long_description"
    t.text     "compliance_means"
    t.string   "is_covered"
    t.text     "cover_detail"
    t.date     "last_review"
  end

  create_table "review_types", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.boolean  "is_active",   :default => true
  end

  create_table "risks", :force => true do |t|
    t.integer  "project_id"
    t.integer  "probability"
    t.integer  "impact"
    t.text     "context"
    t.text     "risk"
    t.text     "consequence"
    t.text     "actions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_quality",      :default => 1
    t.integer  "generic_risk_id"
    t.integer  "stream_id"
    t.integer  "is_ria_logged",   :default => 0
    t.integer  "is_ria_action",   :default => 0
    t.integer  "old_impact",      :default => 0
    t.integer  "old_probability", :default => 0
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "display"
    t.text   "description"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sdp_activities", :force => true do |t|
    t.integer  "phase_id"
    t.string   "title"
    t.float    "initial"
    t.float    "reevaluated"
    t.float    "assigned"
    t.float    "consumed"
    t.float    "remaining"
    t.float    "revised"
    t.float    "gained"
    t.float    "iteration"
    t.float    "collab"
    t.float    "balancei"
    t.float    "balancer"
    t.float    "balancea"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sdp_activities_by_type", :force => true do |t|
    t.integer  "phase_id"
    t.string   "request_type"
    t.string   "title"
    t.float    "initial"
    t.float    "reevaluated"
    t.float    "assigned"
    t.float    "consumed"
    t.float    "remaining"
    t.float    "revised"
    t.float    "gained"
    t.float    "iteration"
    t.float    "collab"
    t.float    "balancei"
    t.float    "balancer"
    t.float    "balancea"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sdp_constants", :force => true do |t|
    t.string   "constant_name"
    t.float    "constant_value"
    t.string   "constant_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sdp_import_logs", :force => true do |t|
    t.decimal  "sdp_initial_balance",             :precision => 10, :scale => 3
    t.decimal  "sdp_real_balance",                :precision => 10, :scale => 3
    t.decimal  "sdp_real_balance_and_provisions", :precision => 10, :scale => 3
    t.decimal  "operational_total_minus_om",      :precision => 10, :scale => 3
    t.decimal  "not_included_remaining",          :precision => 10, :scale => 3
    t.decimal  "provisions",                      :precision => 10, :scale => 3
    t.decimal  "sold",                            :precision => 10, :scale => 3
    t.decimal  "remaining_time",                  :precision => 10, :scale => 3
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sdp_logs", :force => true do |t|
    t.integer  "person_id"
    t.date     "date"
    t.float    "initial"
    t.float    "sdp_remaining"
    t.float    "wl_remaining"
    t.float    "delay"
    t.float    "balance"
    t.float    "percent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sdp_phases", :force => true do |t|
    t.string   "title"
    t.float    "initial"
    t.float    "reevaluated"
    t.float    "assigned"
    t.float    "consumed"
    t.float    "remaining"
    t.float    "revised"
    t.float    "gained"
    t.float    "iteration"
    t.float    "collab"
    t.decimal  "balancei",    :precision => 10, :scale => 3
    t.float    "balancer"
    t.float    "balancea"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sdp_phases_by_type", :force => true do |t|
    t.string   "request_type"
    t.string   "title"
    t.float    "initial"
    t.float    "reevaluated"
    t.float    "assigned"
    t.float    "consumed"
    t.float    "remaining"
    t.float    "revised"
    t.float    "gained"
    t.float    "iteration"
    t.float    "collab"
    t.float    "balancei"
    t.float    "balancer"
    t.float    "balancea"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sdp_tasks", :force => true do |t|
    t.integer  "sdp_id"
    t.integer  "activity_id"
    t.integer  "phase_id"
    t.string   "title"
    t.string   "request_id"
    t.integer  "done",                :default => 0
    t.float    "initial"
    t.float    "reevaluated"
    t.float    "assigned"
    t.float    "consumed"
    t.float    "remaining"
    t.float    "revised"
    t.float    "gained"
    t.string   "iteration"
    t.string   "collab"
    t.float    "balancei"
    t.float    "balancer"
    t.float    "balancea"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activity_by_type_id"
    t.integer  "phase_by_type_id"
    t.string   "project_code"
  end

  create_table "spider_consolidations", :force => true do |t|
    t.integer  "spider_id"
    t.integer  "pm_type_axe_id"
    t.float    "average"
    t.float    "average_ref"
    t.integer  "ni_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spider_consolidations", ["spider_id"], :name => "IDX_SPIDER_CONSOLIDATIONS"

  create_table "spider_values", :force => true do |t|
    t.integer  "lifecycle_question_id"
    t.integer  "spider_id"
    t.string   "note"
    t.string   "reference"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "recursive",             :default => false
  end

  create_table "spiders", :force => true do |t|
    t.integer  "project_id"
    t.integer  "milestone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_link"
    t.boolean  "impact_count", :default => false
  end

  add_index "spiders", ["milestone_id"], :name => "IDX_SPIDERS"

  create_table "squads", :force => true do |t|
    t.string   "name"
    t.string   "supervisor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.integer  "project_id",                                                :null => false
    t.integer  "status",                 :default => 0
    t.text     "explanation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feedback"
    t.text     "reason"
    t.text     "operational_alert"
    t.text     "last_change"
    t.text     "actions"
    t.string   "ereporting_date"
    t.text     "explanation_diffs"
    t.text     "last_change_diffs"
    t.text     "last_change_excel"
    t.integer  "last_modifier"
    t.integer  "locked",                 :default => 0
    t.datetime "locked_time"
    t.text     "reporting"
    t.datetime "reason_updated_at",      :default => '2011-07-19 09:15:21'
    t.datetime "reporting_at",           :default => '2011-07-19 09:15:21'
    t.text     "pratice_spider_gap"
    t.text     "deliverable_spider_gap"
    t.boolean  "is_support"
  end

  add_index "statuses", ["project_id"], :name => "IDX_STATUSES"

  create_table "stream_review_types", :force => true do |t|
    t.integer  "stream_id"
    t.integer  "review_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stream_reviews", :force => true do |t|
    t.integer  "stream_id"
    t.integer  "review_type_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
    t.text     "text_diff"
  end

  create_table "streams", :force => true do |t|
    t.string   "name"
    t.integer  "workstream_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "read_date"
    t.integer  "supervisor_id"
    t.string   "quality_manager"
    t.string   "dwl"
    t.string   "process_owner"
    t.text     "description"
  end

  create_table "suite_tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",  :default => true
  end

  create_table "svf_deviation_activities", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",                      :default => true
    t.integer  "svf_deviation_meta_activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_activity_deliverables", :force => true do |t|
    t.integer  "svf_deviation_activity_id"
    t.integer  "svf_deviation_deliverable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_deliverables", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_macro_activities", :force => true do |t|
    t.integer  "svf_deviation_activity_id"
    t.string   "name"
    t.boolean  "is_active",                 :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_macro_activity_deliverable_flights", :force => true do |t|
    t.string   "svf_deviation_macro_activity_name"
    t.string   "svf_deviation_deliverable_name"
    t.string   "svf_deviation_activity_name"
    t.integer  "project_id"
    t.string   "answer_1"
    t.string   "answer_2"
    t.string   "answer_3"
    t.string   "justification"
    t.integer  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_macro_activity_deliverables", :force => true do |t|
    t.integer  "svf_deviation_macro_activity_id"
    t.integer  "svf_deviation_deliverable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_meta_activities", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "meta_index"
  end

  create_table "svf_deviation_question_lifecycles", :force => true do |t|
    t.integer  "svf_deviation_question_id"
    t.integer  "lifecycle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_question_milestone_names", :force => true do |t|
    t.integer  "svf_deviation_question_id"
    t.integer  "milestone_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_questions", :force => true do |t|
    t.integer  "svf_deviation_deliverable_id"
    t.integer  "svf_deviation_activity_id"
    t.text     "question_text"
    t.boolean  "is_active",                    :default => true
    t.boolean  "answer_reference",             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_spider_activity_values", :force => true do |t|
    t.integer  "svf_deviation_spider_id"
    t.integer  "svf_deviation_activity_id"
    t.integer  "yes_counter"
    t.integer  "no_counter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_spider_consolidation_temps", :force => true do |t|
    t.integer  "svf_deviation_spider_id"
    t.integer  "svf_deviation_deliverable_id"
    t.integer  "svf_deviation_activity_id"
    t.integer  "score"
    t.string   "justification",                :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_spider_consolidations", :force => true do |t|
    t.integer  "svf_deviation_spider_id"
    t.integer  "svf_deviation_deliverable_id"
    t.integer  "svf_deviation_activity_id"
    t.integer  "score"
    t.text     "justification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_spider_deliverable_values", :force => true do |t|
    t.integer  "svf_deviation_spider_id"
    t.integer  "svf_deviation_deliverable_id"
    t.integer  "yes_counter"
    t.integer  "no_counter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_spider_deliverables", :force => true do |t|
    t.integer  "svf_deviation_spider_id"
    t.integer  "svf_deviation_deliverable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "not_done",                     :default => false
    t.boolean  "is_added_by_hand",             :default => false
  end

  create_table "svf_deviation_spider_maturities", :force => true do |t|
    t.integer  "svf_deviation_spider_id"
    t.integer  "svf_deviation_deliverable_id"
    t.string   "planned"
    t.string   "achieved"
    t.string   "comment"
    t.boolean  "is_consolidated",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_spider_references", :force => true do |t|
    t.integer  "project_id"
    t.integer  "version_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_spider_settings", :force => true do |t|
    t.integer  "svf_deviation_spider_reference_id"
    t.string   "deliverable_name"
    t.string   "activity_name"
    t.string   "answer_1"
    t.string   "answer_2"
    t.string   "answer_3"
    t.text     "justification"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "macro_activity_name"
  end

  create_table "svf_deviation_spider_values", :force => true do |t|
    t.integer  "svf_deviation_spider_deliverable_id"
    t.integer  "svf_deviation_question_id"
    t.boolean  "answer"
    t.boolean  "answer_reference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svf_deviation_spiders", :force => true do |t|
    t.integer  "milestone_id"
    t.boolean  "impact_count", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_link"
    t.integer  "project_id"
  end

  create_table "svt_deviation_activities", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",                      :default => true
    t.integer  "svt_deviation_meta_activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_activity_deliverables", :force => true do |t|
    t.integer  "svt_deviation_activity_id"
    t.integer  "svt_deviation_deliverable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_deliverables", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_macro_activities", :force => true do |t|
    t.integer  "svt_deviation_activity_id"
    t.string   "name"
    t.boolean  "is_active",                 :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_macro_activity_deliverable_flights", :force => true do |t|
    t.string   "svt_deviation_macro_activity_name"
    t.string   "svt_deviation_deliverable_name"
    t.string   "svt_deviation_activity_name"
    t.integer  "project_id"
    t.string   "answer_1"
    t.string   "answer_2"
    t.string   "answer_3"
    t.string   "justification"
    t.integer  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_macro_activity_deliverables", :force => true do |t|
    t.integer  "svt_deviation_macro_activity_id"
    t.integer  "svt_deviation_deliverable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_meta_activities", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "meta_index"
  end

  create_table "svt_deviation_question_lifecycles", :force => true do |t|
    t.integer  "svt_deviation_question_id"
    t.integer  "lifecycle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_question_milestone_names", :force => true do |t|
    t.integer  "svt_deviation_question_id"
    t.integer  "milestone_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_questions", :force => true do |t|
    t.integer  "svt_deviation_deliverable_id"
    t.integer  "svt_deviation_activity_id"
    t.text     "question_text"
    t.boolean  "is_active",                    :default => true
    t.boolean  "answer_reference",             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_spider_activity_values", :force => true do |t|
    t.integer  "svt_deviation_spider_id"
    t.integer  "svt_deviation_activity_id"
    t.integer  "yes_counter"
    t.integer  "no_counter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_spider_consolidation_temps", :force => true do |t|
    t.integer  "svt_deviation_spider_id"
    t.integer  "svt_deviation_deliverable_id"
    t.integer  "svt_deviation_activity_id"
    t.integer  "score"
    t.string   "justification",                :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_spider_consolidations", :force => true do |t|
    t.integer  "svt_deviation_spider_id"
    t.integer  "svt_deviation_deliverable_id"
    t.integer  "svt_deviation_activity_id"
    t.integer  "score"
    t.text     "justification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_spider_deliverable_values", :force => true do |t|
    t.integer  "svt_deviation_spider_id"
    t.integer  "svt_deviation_deliverable_id"
    t.integer  "yes_counter"
    t.integer  "no_counter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_spider_deliverables", :force => true do |t|
    t.integer  "svt_deviation_spider_id"
    t.integer  "svt_deviation_deliverable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "not_done",                     :default => false
    t.boolean  "is_added_by_hand",             :default => false
  end

  create_table "svt_deviation_spider_maturities", :force => true do |t|
    t.integer  "svt_deviation_spider_id"
    t.integer  "svt_deviation_deliverable_id"
    t.string   "planned"
    t.string   "achieved"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_consolidated",              :limit => 1, :default => 0
  end

  create_table "svt_deviation_spider_references", :force => true do |t|
    t.integer  "project_id"
    t.integer  "version_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_spider_settings", :force => true do |t|
    t.integer  "svt_deviation_spider_reference_id"
    t.string   "deliverable_name"
    t.string   "activity_name"
    t.string   "answer_1"
    t.string   "answer_2"
    t.string   "answer_3"
    t.text     "justification"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "macro_activity_name"
  end

  create_table "svt_deviation_spider_values", :force => true do |t|
    t.integer  "svt_deviation_spider_deliverable_id"
    t.integer  "svt_deviation_question_id"
    t.boolean  "answer"
    t.boolean  "answer_reference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "svt_deviation_spiders", :force => true do |t|
    t.integer  "milestone_id"
    t.boolean  "impact_count", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_link"
    t.integer  "project_id"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "planning_id"
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.float    "work_in_day"
    t.float    "person_nb"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "team_size",   :default => 0.0
    t.text     "color"
  end

  create_table "tbp_collab_works", :force => true do |t|
    t.integer  "tbp_collab_id"
    t.date     "date"
    t.integer  "tbp_project_id"
    t.float    "workload"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tbp_collabs", :force => true do |t|
    t.integer  "tbp_id"
    t.string   "firstname"
    t.string   "lastname"
    t.integer  "activity"
    t.integer  "profil"
    t.integer  "te"
    t.integer  "account_index"
    t.datetime "last_update"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tbp_projects", :force => true do |t|
    t.integer  "tbp_id"
    t.string   "name"
    t.integer  "activity"
    t.integer  "ttype"
    t.string   "agresso"
    t.integer  "account_index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.text     "topic"
    t.text     "decision"
    t.integer  "person_id"
    t.integer  "done",        :default => 0
    t.datetime "done_date"
    t.integer  "private",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sqli_action", :default => 0
  end

  create_table "wl_backups", :force => true do |t|
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
    t.integer  "backup_person_id"
    t.integer  "week"
  end

  create_table "wl_holidays", :force => true do |t|
    t.integer  "week"
    t.integer  "nb"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wl_holidays_calendar_id"
  end

  create_table "wl_line_tasks", :force => true do |t|
    t.integer "wl_line_id"
    t.integer "sdp_task_id"
  end

  create_table "wl_lines", :force => true do |t|
    t.integer  "person_id"
    t.integer  "request_id"
    t.string   "name"
    t.integer  "wl_type"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_line"
    t.integer  "project_id"
  end

  add_index "wl_lines", ["request_id"], :name => "IDX_WL_LINES"

  create_table "wl_loads", :force => true do |t|
    t.integer  "wl_line_id"
    t.integer  "week"
    t.float    "wlload"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wl_loads", ["wl_line_id"], :name => "IDX_WL_LOADS"

  create_table "workpackages", :force => true do |t|
    t.string "title"
    t.string "shortname"
    t.string "code"
  end

  create_table "workstreams", :force => true do |t|
    t.integer  "supervisor_id"
    t.string   "name"
    t.text     "strenghts"
    t.text     "weaknesses"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
