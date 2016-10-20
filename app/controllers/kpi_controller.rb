require 'spreadsheet'

class KpiController < ApplicationController

	layout 'tools'
  	include WelcomeHelper

	Setting_info    = Struct.new(:project_name, :workpackage, :lifecycle, :workstream, :plm, :typo, :macro_activity_name, :essential_activity, :plan_to_do_activity, :deliverable_name, :essential_deliverable, :plan_to_do)
	OM_info    = Struct.new(:dws, :suite, :lifecycle, :project_name, :workpackage, :milestone, :milestone_date, :business_and_is_modelling, :change_management, :configuration_management, :continuous_improvement, :integration_v_and_v, :measurement_process_and_qm, :monitoring_and_control, :project_justification, :pp_scoping_and_structuring, :risk_and_opportunities_management, :run_mode_preparation, :solution_definition, :subcontracting_management, :risks_management, :planning, :organisation, :project_configuration, :needs_management, :tests_managements, :product_configuration, :technical, :architecture, :integration, :alert)
	Value    = Struct.new(:dws, :suite, :lifecycle, :project_name, :workpackage, :milestone, :activity, :answer)

	def index
	end

	def extract_list_deliverable_SVF
		@settings = Array.new

		SvfDeviationSpiderSetting.find(:all).each do |setting|
			
			unless setting.svf_deviation_spider_reference.project.nil? || setting.svf_deviation_spider_reference.project == 0
			
				setting_info = Setting_info.new
				setting_info.project_name = setting.svf_deviation_spider_reference.project.project_name
				setting_info.workpackage = setting.svf_deviation_spider_reference.project.full_wp_name
				setting_info.lifecycle = setting.svf_deviation_spider_reference.project.lifecycle_object.name
				setting_info.workstream = setting.svf_deviation_spider_reference.project.workstream
				if setting.svf_deviation_spider_reference.project.suite_tag
					setting_info.plm = setting.svf_deviation_spider_reference.project.suite_tag.name
				end
				setting_info.macro_activity_name = setting.macro_activity_name
				setting_info.deliverable_name = setting.deliverable_name
				setting_info.plan_to_do_activity = setting.answer_1
				setting_info.plan_to_do = setting.answer_1
				@settings << setting_info
			
			end
			
		end

		if @settings.count > 0
	        begin
	          @xml = Builder::XmlMarkup.new(:indent => 1)

	          headers['Content-Type']         = "application/vnd.ms-excel"
	          headers['Content-Disposition']  = 'attachment; filename="Deliverable list for KPI SVF.xls"'
	          headers['Cache-Control']        = ''
	          render "deliverable_list_kpi.erb", :layout=>false
	        rescue Exception => e
	          render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
        else
	      render(:text=>"<b>Error</b><br>No SVF PSU imported yet.")
	    end

	end

	def extract_list_deliverable_SVT
		@settings = Array.new

		SvtDeviationSpiderSetting.find(:all).each do |setting|
			
			unless setting.svt_deviation_spider_reference.project.nil? || setting.svt_deviation_spider_reference.project == 0
			
				setting_info = Setting_info.new
				setting_info.project_name = setting.svt_deviation_spider_reference.project.project_name
				setting_info.workpackage = setting.svt_deviation_spider_reference.project.full_wp_name
				setting_info.lifecycle = setting.svt_deviation_spider_reference.project.lifecycle_object.name
				setting_info.workstream = setting.svt_deviation_spider_reference.project.workstream
				if setting.svt_deviation_spider_reference.project.suite_tag
					setting_info.plm = setting.svt_deviation_spider_reference.project.suite_tag.name
				end
				setting_info.macro_activity_name = setting.macro_activity_name
				setting_info.deliverable_name = setting.deliverable_name
				setting_info.plan_to_do_activity = setting.answer_1
				setting_info.plan_to_do = setting.answer_1
				@settings << setting_info
			
			end
			
		end

		if @settings.count > 0
	        begin
	          @xml = Builder::XmlMarkup.new(:indent => 1)

	          headers['Content-Type']         = "application/vnd.ms-excel"
	          headers['Content-Disposition']  = 'attachment; filename="Deliverable list for KPI SVT.xls"'
	          headers['Cache-Control']        = ''
	          render "deliverable_list_kpi.erb", :layout=>false
	        rescue Exception => e
	          render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
        else
	      render(:text=>"<b>Error</b><br>No SVT PSU imported yet.")
	    end

	end

	

    def extract_om_adherence_SVF

    	@om = Array.new

    	#LOOP ON CONSOLIDATED SPIDERS GROUP BY SPIDER (UNIQUE PARSING)
    	SvfDeviationSpiderConsolidation.find(:all, :group => ["svf_deviation_spider_id"]).each do |consolidated|

    		#DECLARING ARRAYS TO STORE VALUES
			business_and_is_modelling = Array.new
			change_management = Array.new
			configuration_management = Array.new
			continuous_improvement = Array.new
			integration_v_and_v = Array.new
			measurement_process_and_qm = Array.new
			monitoring_and_control = Array.new
			project_justification = Array.new
			pp_scoping_and_structuring = Array.new
			risk_and_opportunities_management = Array.new
			run_mode_preparation = Array.new
			solution_definition = Array.new
			subcontracting_management = Array.new

    		#LOOP ON VALUES
    		SvfDeviationSpiderValue.find(:all).each do |answer|

    			#IF ANSWER/VALUE BELONG TO A CONSOLIDATED SPIDER
    			if answer.svf_deviation_spider_deliverable.svf_deviation_spider_id == consolidated.svf_deviation_spider_id

    				#MANUALLY GRAB EACH ACTIVITY
    				if answer.svf_deviation_question.svf_deviation_activity_id == 26 # business_and_is_modelling
    					business_and_is_modelling << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 37 # change_management
    					change_management << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 31 # configuration_management
    					configuration_management << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 38 # continuous_improvement
    					continuous_improvement << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 29 # integration_v_and_v
    					integration_v_and_v << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 32 # measurement_process_and_qm
    					measurement_process_and_qm << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 23 # monitoring_and_control
    					monitoring_and_control << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 34 # project_justification
    					project_justification << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 21 # pp_scoping_and_structuring
    					pp_scoping_and_structuring << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 35 # risk_and_opportunities_management
    					risk_and_opportunities_management << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 30 # run_mode_preparation
    					run_mode_preparation << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 28 # solution_definition
    					solution_definition << (answer.answer ? 1 : 0)
    				elsif answer.svf_deviation_question.svf_deviation_activity_id == 40 # subcontracting_management
    					subcontracting_management << (answer.answer ? 1 : 0)
    				end

    			end

			end

			unless consolidated.svf_deviation_spider.project.nil? || consolidated.svf_deviation_spider.project == 0

				om_info = OM_info.new

				#FOR EACH DATA, GET VALUE FROM CONSOLIDATED SPIDER
				om_info.dws = consolidated.svf_deviation_spider.project.workstream
				if consolidated.svf_deviation_spider.project.suite_tag
					om_info.suite = consolidated.svf_deviation_spider.project.suite_tag.name
				else
					om_info.suite = ""
				end

				#FOR EACH DATA, GET VALUE FROM CONSOLIDATED SPIDER
				om_info.lifecycle = consolidated.svf_deviation_spider.project.lifecycle_object.name
				om_info.project_name = consolidated.svf_deviation_spider.project.project_name
				om_info.workpackage = consolidated.svf_deviation_spider.project.full_wp_name
				om_info.milestone = consolidated.svf_deviation_spider.milestone.name

				milestone_date = ""
				if consolidated.svf_deviation_spider.milestone.actual_milestone_date and consolidated.svf_deviation_spider.milestone.actual_milestone_date != ""
					milestone_date = get_date_from_bdd_date(consolidated.svf_deviation_spider.milestone.actual_milestone_date)
				elsif consolidated.svf_deviation_spider.milestone.milestone_date and consolidated.svf_deviation_spider.milestone.milestone_date != ""
					milestone_date = get_date_from_bdd_date(consolidated.svf_deviation_spider.milestone.milestone_date)
				end
				om_info.milestone_date = milestone_date

				#FOR EACH ACTIVITY, GET VALUE FROM VALUES ARRAYS AND STORE THE AVERAGE
				om_info.business_and_is_modelling = !business_and_is_modelling.empty? ? ((business_and_is_modelling.inject{ |sum, el| sum + el }.to_f / business_and_is_modelling.size) * 100).round(2) : ""
				om_info.change_management = !change_management.empty? ? ((change_management.inject{ |sum, el| sum + el }.to_f / change_management.size) * 100).round(2) : ""
				om_info.configuration_management = !configuration_management.empty? ? ((configuration_management.inject{ |sum, el| sum + el }.to_f / configuration_management.size) * 100).round(2) : ""
				om_info.continuous_improvement = !continuous_improvement.empty? ? ((continuous_improvement.inject{ |sum, el| sum + el }.to_f / continuous_improvement.size) * 100).round(2) : ""
				om_info.integration_v_and_v = !integration_v_and_v.empty? ? ((integration_v_and_v.inject{ |sum, el| sum + el }.to_f / integration_v_and_v.size) * 100).round(2) : ""
				om_info.measurement_process_and_qm = !measurement_process_and_qm.empty? ? ((measurement_process_and_qm.inject{ |sum, el| sum + el }.to_f / measurement_process_and_qm.size) * 100).round(2) : ""
				om_info.monitoring_and_control = !monitoring_and_control.empty? ? ((monitoring_and_control.inject{ |sum, el| sum + el }.to_f / monitoring_and_control.size) * 100).round(2) : ""
				om_info.project_justification = !project_justification.empty? ? ((project_justification.inject{ |sum, el| sum + el }.to_f / project_justification.size) * 100).round(2) : ""
				om_info.pp_scoping_and_structuring = !pp_scoping_and_structuring.empty? ? ((pp_scoping_and_structuring.inject{ |sum, el| sum + el }.to_f / pp_scoping_and_structuring.size) * 100).round(2) : ""
				om_info.risk_and_opportunities_management = !risk_and_opportunities_management.empty? ? ((risk_and_opportunities_management.inject{ |sum, el| sum + el }.to_f / risk_and_opportunities_management.size) * 100).round(2) : ""
				om_info.run_mode_preparation = !run_mode_preparation.empty? ? ((run_mode_preparation.inject{ |sum, el| sum + el }.to_f / run_mode_preparation.size) * 100).round(2) : ""
				om_info.solution_definition = !solution_definition.empty? ? ((solution_definition.inject{ |sum, el| sum + el }.to_f / solution_definition.size) * 100).round(2) : ""
				om_info.subcontracting_management = !subcontracting_management.empty? ? ((subcontracting_management.inject{ |sum, el| sum + el }.to_f / subcontracting_management.size) * 100).round(2) : ""


				filled_organisation = 4
				if om_info.continuous_improvement == ""
					om_info.continuous_improvement = 0
					filled_organisation -= 1
				end
				if om_info.measurement_process_and_qm == ""
					om_info.measurement_process_and_qm = 0
					filled_organisation -= 1
				end
				if om_info.monitoring_and_control == ""
					om_info.monitoring_and_control = 0
					filled_organisation -= 1
				end
				if om_info.subcontracting_management == ""
					om_info.subcontracting_management = 0
					filled_organisation -= 1
				end

				om_info.organisation = ""
				if filled_organisation != 0
					orga = (om_info.continuous_improvement + om_info.measurement_process_and_qm + om_info.monitoring_and_control + om_info.subcontracting_management) / filled_organisation
					if orga != ""
						om_info.organisation = orga.round(2)
					end
				end

				filled_needs_management = 3
				if om_info.business_and_is_modelling == ""
					om_info.business_and_is_modelling = 0
					filled_needs_management -= 1
				end
				if om_info.change_management == ""
					om_info.change_management = 0
					filled_needs_management -= 1
				end
				if om_info.project_justification == ""
					om_info.project_justification = 0
					filled_needs_management -= 1
				end

				om_info.needs_management = ""
				if filled_needs_management != 0
					needs = (om_info.business_and_is_modelling + om_info.change_management + om_info.project_justification) / filled_needs_management
					if needs != ""
						om_info.needs_management = needs.round(2)
					end
				end


				if om_info.risk_and_opportunities_management != ""
					om_info.risks_management = om_info.risk_and_opportunities_management.round(2)
				end

				if om_info.pp_scoping_and_structuring != ""
					om_info.planning = om_info.pp_scoping_and_structuring.round(2)
				end

				if om_info.configuration_management != ""
					om_info.project_configuration = om_info.configuration_management.round(2)
				end

				if om_info.integration_v_and_v != ""
					om_info.tests_managements = om_info.integration_v_and_v.round(2)
				end

				if om_info.product_configuration != ""
					om_info.product_configuration = "" #tbd
				end

				if om_info.technical != ""
					om_info.technical = "" #tbd
				end

				if om_info.solution_definition != ""
					om_info.architecture = om_info.solution_definition.round(2)
				end

				@om << om_info

			end

		end

		if @om.count > 0
	        begin
	          @xml = Builder::XmlMarkup.new(:indent => 1)

	          headers['Content-Type']         = "application/vnd.ms-excel"
	          headers['Content-Disposition']  = 'attachment; filename="E-M&T_Ref_&_OM_adherence_KPI Data_Adherence_SVF.xls"'
	          headers['Cache-Control']        = ''
	          render "om_adherence.erb", :layout=>false
	        rescue Exception => e
	          render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
        else
        	render(:text=>"<b>Error</b><br>No SVF spiders consolidated yet.")
	    end

	end

    def extract_om_adherence_SVT

    	@om = Array.new

    	#LOOP ON CONSOLIDATED SPIDERS GROUP BY SPIDER (UNIQUE PARSING)
    	SvtDeviationSpiderConsolidation.find(:all, :group => ["svt_deviation_spider_id"]).each do |consolidated|

    		#DECLARING ARRAYS TO STORE VALUES
			business_and_is_modelling = Array.new
			change_management = Array.new
			configuration_management = Array.new
			continuous_improvement = Array.new
			integration_v_and_v = Array.new
			measurement_process_and_qm = Array.new
			monitoring_and_control = Array.new
			project_justification = Array.new
			pp_scoping_and_structuring = Array.new
			risk_and_opportunities_management = Array.new
			run_mode_preparation = Array.new
			solution_definition = Array.new
			subcontracting_management = Array.new

    		#LOOP ON VALUES
    		SvtDeviationSpiderValue.find(:all).each do |answer|

    			#IF ANSWER/VALUE BELONG TO A CONSOLIDATED SPIDER
    			if answer.svt_deviation_spider_deliverable.svt_deviation_spider_id == consolidated.svt_deviation_spider_id

    				#MANUALLY GRAB EACH ACTIVITY
    				if answer.svt_deviation_question.svt_deviation_activity_id == 26 # business_and_is_modelling
    					business_and_is_modelling << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 37 # change_management
    					change_management << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 31 # configuration_management
    					configuration_management << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 38 # continuous_improvement
    					continuous_improvement << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 29 # integration_v_and_v
    					integration_v_and_v << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 32 # measurement_process_and_qm
    					measurement_process_and_qm << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 23 # monitoring_and_control
    					monitoring_and_control << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 34 # project_justification
    					project_justification << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 21 # pp_scoping_and_structuring
    					pp_scoping_and_structuring << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 35 # risk_and_opportunities_management
    					risk_and_opportunities_management << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 30 # run_mode_preparation
    					run_mode_preparation << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 28 # solution_definition
    					solution_definition << (answer.answer ? 1 : 0)
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 24 # subcontracting_management
    					subcontracting_management << (answer.answer ? 1 : 0)
    				end

    			end

			end

			unless consolidated.svt_deviation_spider.project.nil? || consolidated.svt_deviation_spider.project == 0

				om_info = OM_info.new

				#FOR EACH DATA, GET VALUE FROM CONSOLIDATED SPIDER
				om_info.dws = consolidated.svt_deviation_spider.project.workstream
				if consolidated.svt_deviation_spider.project.suite_tag
					om_info.suite = consolidated.svt_deviation_spider.project.suite_tag.name
				else
					om_info.suite = ""
				end

				#FOR EACH DATA, GET VALUE FROM CONSOLIDATED SPIDER
				om_info.lifecycle = consolidated.svt_deviation_spider.project.lifecycle_object.name
				om_info.project_name = consolidated.svt_deviation_spider.project.project_name
				om_info.workpackage = consolidated.svt_deviation_spider.project.full_wp_name
				om_info.milestone = consolidated.svt_deviation_spider.milestone.name
				

				milestone_date = ""
				if consolidated.svf_deviation_spider.milestone.actual_milestone_date and consolidated.svf_deviation_spider.milestone.actual_milestone_date != ""
					milestone_date = get_date_from_bdd_date(consolidated.svf_deviation_spider.milestone.actual_milestone_date)
				elsif consolidated.svf_deviation_spider.milestone.milestone_date and consolidated.svf_deviation_spider.milestone.milestone_date != ""
					milestone_date = consolidated.svf_deviation_spider.milestone.milestone_date
				end
				om_info.milestone_date = milestone_date

				#FOR EACH ACTIVITY, GET VALUE FROM VALUES ARRAYS AND STORE THE AVERAGE
				om_info.business_and_is_modelling = !business_and_is_modelling.empty? ? ((business_and_is_modelling.inject{ |sum, el| sum + el }.to_f / business_and_is_modelling.size) * 100).round(2) : ""
				om_info.change_management = !change_management.empty? ? ((change_management.inject{ |sum, el| sum + el }.to_f / change_management.size) * 100).round(2) : ""
				om_info.configuration_management = !configuration_management.empty? ? ((configuration_management.inject{ |sum, el| sum + el }.to_f / configuration_management.size) * 100).round(2) : ""
				om_info.continuous_improvement = !continuous_improvement.empty? ? ((continuous_improvement.inject{ |sum, el| sum + el }.to_f / continuous_improvement.size) * 100).round(2) : ""
				om_info.integration_v_and_v = !integration_v_and_v.empty? ? ((integration_v_and_v.inject{ |sum, el| sum + el }.to_f / integration_v_and_v.size) * 100).round(2) : ""
				om_info.measurement_process_and_qm = !measurement_process_and_qm.empty? ? ((measurement_process_and_qm.inject{ |sum, el| sum + el }.to_f / measurement_process_and_qm.size) * 100).round(2) : ""
				om_info.monitoring_and_control = !monitoring_and_control.empty? ? ((monitoring_and_control.inject{ |sum, el| sum + el }.to_f / monitoring_and_control.size) * 100).round(2) : ""
				om_info.project_justification = !project_justification.empty? ? ((project_justification.inject{ |sum, el| sum + el }.to_f / project_justification.size) * 100).round(2) : ""
				om_info.pp_scoping_and_structuring = !pp_scoping_and_structuring.empty? ? ((pp_scoping_and_structuring.inject{ |sum, el| sum + el }.to_f / pp_scoping_and_structuring.size) * 100).round(2) : ""
				om_info.risk_and_opportunities_management = !risk_and_opportunities_management.empty? ? ((risk_and_opportunities_management.inject{ |sum, el| sum + el }.to_f / risk_and_opportunities_management.size) * 100).round(2) : ""
				om_info.run_mode_preparation = !run_mode_preparation.empty? ? ((run_mode_preparation.inject{ |sum, el| sum + el }.to_f / run_mode_preparation.size) * 100).round(2) : ""
				om_info.solution_definition = !solution_definition.empty? ? ((solution_definition.inject{ |sum, el| sum + el }.to_f / solution_definition.size) * 100).round(2) : ""
				om_info.subcontracting_management = !subcontracting_management.empty? ? ((subcontracting_management.inject{ |sum, el| sum + el }.to_f / subcontracting_management.size) * 100).round(2) : ""
				
				@om << om_info

			end

		end

		if @om.count > 0
	        begin
	          @xml = Builder::XmlMarkup.new(:indent => 1)

	          headers['Content-Type']         = "application/vnd.ms-excel"
	          headers['Content-Disposition']  = 'attachment; filename="E-M&T_Ref_&_OM_adherence_KPI Data_Adherence_SVT.xls"'
	          headers['Cache-Control']        = ''
	          render "om_adherence.erb", :layout=>false
	        rescue Exception => e
	          render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
        else
        	render(:text=>"<b>Error</b><br>No SVT spiders consolidated yet.")
	    end

	end

	def get_date_from_bdd_date(bdd_date)
    date_split = bdd_date.to_s.split("-")
    if date_split[2] and date_split[2] != "" and date_split[2].length < 4
    	date = date_split[2] + "-" + date_split[1] + "-" + date_split[0]
    elsif date_split[2] and date_split[2] != "" and date_split[2].length > 2
    	date = date_split[0] + "-" + date_split[1] + "-" + date_split[2]
    else
    	date = date_split
    end

    return date
  end

end