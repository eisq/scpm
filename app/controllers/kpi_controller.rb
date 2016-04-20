require 'spreadsheet'

class KpiController < ApplicationController

	layout 'tools'
  	include WelcomeHelper

	Setting_info    = Struct.new(:project_name, :workpackage, :lifecycle, :workstream, :plm, :activity_name, :macro_activity_name, :deliverable_name, :plan_to_do)
	OM_info    = Struct.new(:dws, :suite, :lifecycle, :project_name, :workpackage, :milestone, :business_and_is_modelling, :change_management, :configuration_management, :continuous_improvement, :integration_v_and_v, :measurement_process_and_qm, :monitoring_and_control, :project_justification, :pp_scoping_and_structuring, :risk_and_opportunities_management, :run_mode_preparation, :solution_definition, :subcontracting_management, :risks_management, :planning, :organisation, :project_configuration, :needs_management, :tests_managements, :product_configuration, :technical, :architecture, :integration, :alert)
	Value    = Struct.new(:dws, :suite, :lifecycle, :project_name, :workpackage, :milestone, :activity, :answer)

	def index
	end

	def extract_list_deliverable
		@settings = Array.new

		#DeviationSpiderSetting.find(:all).each do |setting|
		#	setting_info = Setting_info.new
		#	setting_info.plm = ""
		#	setting_info.lifecycle = ""
		#	if setting.deviation_spider_reference.project
		#		setting_info.lifecycle = setting.deviation_spider_reference.project.lifecycle_object.name
		#		setting_info.workstream = setting.deviation_spider_reference.project.workstream
		#		if setting.deviation_spider_reference.project.suite_tag
		#			setting_info.plm = setting.deviation_spider_reference.project.suite_tag.name
		#		end
		#		setting_info.activity_name = setting.activity_name
		#		setting_info.deliverable_name = setting.deliverable_name
		#		setting_info.plan_to_do = setting.answer_1
		#		@settings << setting_info
		#	end
		#end

		SvtDeviationSpiderSetting.find(:all).each do |setting|
			setting_info = Setting_info.new
			setting_info.project_name = setting.svt_deviation_spider_reference.project.project_name
			setting_info.workpackage = setting.svt_deviation_spider_reference.project.full_wp_name
			setting_info.lifecycle = setting.svt_deviation_spider_reference.project.lifecycle_object.name
			setting_info.workstream = setting.svt_deviation_spider_reference.project.workstream
			if setting.svt_deviation_spider_reference.project.suite_tag
				setting_info.plm = setting.svt_deviation_spider_reference.project.suite_tag.name
			end
			setting_info.activity_name = setting.activity_name
			setting_info.macro_activity_name = setting.macro_activity_name
			setting_info.deliverable_name = setting.deliverable_name
			setting_info.plan_to_do = setting.answer_1
			@settings << setting_info
		end

		#SvfDeviationSpiderSetting.find(:all).each do |setting|
		#	setting_info = Setting_info.new
		#	setting_info.plm = ""
		#	setting_info.lifecycle = setting.svf_deviation_spider_reference.project.lifecycle_object.name
		#	setting_info.workstream = setting.svf_deviation_spider_reference.project.workstream
		#	if setting.svf_deviation_spider_reference.project.suite_tag
		#		setting_info.plm = setting.svf_deviation_spider_reference.project.suite_tag.name
		#	end
		#	setting_info.activity_name = setting.activity_name
		#	setting_info.deliverable_name = setting.deliverable_name
		#	setting_info.plan_to_do = setting.answer_1
		#	@settings << setting_info
		#end

		if @settings.count > 0
	        begin
	          @xml = Builder::XmlMarkup.new(:indent => 1)

	          headers['Content-Type']         = "application/vnd.ms-excel"
	          headers['Content-Disposition']  = 'attachment; filename="Deliverable list for KPI.xls"'
	          headers['Cache-Control']        = ''
	          render "deliverable_list_kpi.erb", :layout=>false
	        rescue Exception => e
	          render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
	    end

	end

    def extract_om_adherence

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

			#FOR EACH ACTIVITY, GET VALUE FROM VALUES ARRAYS AND STORE THE AVERAGE
			om_info.business_and_is_modelling = !business_and_is_modelling.empty? ? (business_and_is_modelling.inject{ |sum, el| sum + el }.to_f / business_and_is_modelling.size).round(2) : ""
			om_info.change_management = !change_management.empty? ? (change_management.inject{ |sum, el| sum + el }.to_f / change_management.size).round(2) : ""
			om_info.configuration_management = !configuration_management.empty? ? (configuration_management.inject{ |sum, el| sum + el }.to_f / configuration_management.size).round(2) : ""
			om_info.continuous_improvement = !continuous_improvement.empty? ? (continuous_improvement.inject{ |sum, el| sum + el }.to_f / continuous_improvement.size).round(2) : ""
			om_info.integration_v_and_v = !integration_v_and_v.empty? ? (integration_v_and_v.inject{ |sum, el| sum + el }.to_f / integration_v_and_v.size).round(2) : ""
			om_info.measurement_process_and_qm = !measurement_process_and_qm.empty? ? (measurement_process_and_qm.inject{ |sum, el| sum + el }.to_f / measurement_process_and_qm.size).round(2) : ""
			om_info.monitoring_and_control = !monitoring_and_control.empty? ? (monitoring_and_control.inject{ |sum, el| sum + el }.to_f / monitoring_and_control.size).round(2) : ""
			om_info.project_justification = !project_justification.empty? ? (project_justification.inject{ |sum, el| sum + el }.to_f / project_justification.size).round(2) : ""
			om_info.pp_scoping_and_structuring = !pp_scoping_and_structuring.empty? ? (pp_scoping_and_structuring.inject{ |sum, el| sum + el }.to_f / pp_scoping_and_structuring.size).round(2) : ""
			om_info.risk_and_opportunities_management = !risk_and_opportunities_management.empty? ? (risk_and_opportunities_management.inject{ |sum, el| sum + el }.to_f / risk_and_opportunities_management.size).round(2) : ""
			om_info.run_mode_preparation = !run_mode_preparation.empty? ? (run_mode_preparation.inject{ |sum, el| sum + el }.to_f / run_mode_preparation.size).round(2) : ""
			om_info.solution_definition = !solution_definition.empty? ? (solution_definition.inject{ |sum, el| sum + el }.to_f / solution_definition.size).round(2) : ""
			om_info.subcontracting_management = !subcontracting_management.empty? ? (subcontracting_management.inject{ |sum, el| sum + el }.to_f / subcontracting_management.size).round(2) : ""
			
			@om << om_info

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
    				elsif answer.svt_deviation_question.svt_deviation_activity_id == 40 # subcontracting_management
    					subcontracting_management << (answer.answer ? 1 : 0)
    				end

    			end

			end

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

			#FOR EACH ACTIVITY, GET VALUE FROM VALUES ARRAYS AND STORE THE AVERAGE
			om_info.business_and_is_modelling = !business_and_is_modelling.empty? ? (business_and_is_modelling.inject{ |sum, el| sum + el }.to_f / business_and_is_modelling.size).round(2) : ""
			om_info.change_management = !change_management.empty? ? (change_management.inject{ |sum, el| sum + el }.to_f / change_management.size).round(2) : ""
			om_info.configuration_management = !configuration_management.empty? ? (configuration_management.inject{ |sum, el| sum + el }.to_f / configuration_management.size).round(2) : ""
			om_info.continuous_improvement = !continuous_improvement.empty? ? (continuous_improvement.inject{ |sum, el| sum + el }.to_f / continuous_improvement.size).round(2) : ""
			om_info.integration_v_and_v = !integration_v_and_v.empty? ? (integration_v_and_v.inject{ |sum, el| sum + el }.to_f / integration_v_and_v.size).round(2) : ""
			om_info.measurement_process_and_qm = !measurement_process_and_qm.empty? ? (measurement_process_and_qm.inject{ |sum, el| sum + el }.to_f / measurement_process_and_qm.size).round(2) : ""
			om_info.monitoring_and_control = !monitoring_and_control.empty? ? (monitoring_and_control.inject{ |sum, el| sum + el }.to_f / monitoring_and_control.size).round(2) : ""
			om_info.project_justification = !project_justification.empty? ? (project_justification.inject{ |sum, el| sum + el }.to_f / project_justification.size).round(2) : ""
			om_info.pp_scoping_and_structuring = !pp_scoping_and_structuring.empty? ? (pp_scoping_and_structuring.inject{ |sum, el| sum + el }.to_f / pp_scoping_and_structuring.size).round(2) : ""
			om_info.risk_and_opportunities_management = !risk_and_opportunities_management.empty? ? (risk_and_opportunities_management.inject{ |sum, el| sum + el }.to_f / risk_and_opportunities_management.size).round(2) : ""
			om_info.run_mode_preparation = !run_mode_preparation.empty? ? (run_mode_preparation.inject{ |sum, el| sum + el }.to_f / run_mode_preparation.size).round(2) : ""
			om_info.solution_definition = !solution_definition.empty? ? (solution_definition.inject{ |sum, el| sum + el }.to_f / solution_definition.size).round(2) : ""
			om_info.subcontracting_management = !subcontracting_management.empty? ? (subcontracting_management.inject{ |sum, el| sum + el }.to_f / subcontracting_management.size).round(2) : ""
			
			@om << om_info

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

end