require 'spreadsheet'

class KpiController < ApplicationController

	layout 'tools'
  	include WelcomeHelper

	Setting_info    = Struct.new(:project_name, :workpackage, :lifecycle, :workstream, :plm, :activity_name, :macro_activity_name, :deliverable_name, :plan_to_do)
	OM_info    = Struct.new(:dws, :suite, :lifecycle, :project_name, :workpackage, :milestone, :business_and_is_modelling, :change_management, :configuration_management, :continuous_improvement, :integration_v_and_v, :measurement_process_and_qm, :monitoring_and_control, :project_justification, :pp_scoping_and_structuring, :risk_and_opportunities_management, :run_mode_preparation, :solution_definition, :subcontracting_management, :risks_management, :planning, :organisation, :project_configuration, :needs_management, :tests_managements, :product_configuration, :technical, :architecture, :integration, :alert)

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

		SvtDeviationSpiderSetting.find(:all).each do |spider|
			om_info = OM_info.new

			om_info.dws = spider.svt_deviation_spider_reference.project.workstream
			if spider.svt_deviation_spider_reference.project.suite_tag
				om_info.suite = spider.svt_deviation_spider_reference.project.suite_tag.name
			else
				om_info.suite = ""
			end
			om_info.lifecycle = spider.svt_deviation_spider_reference.project.lifecycle_object.name
			om_info.project_name = spider.svt_deviation_spider_reference.project.project_name
			om_info.workpackage = spider.svt_deviation_spider_reference.project.full_wp_name
			om_info.milestone = ""
			om_info.business_and_is_modelling = ""
			om_info.change_management = ""
			om_info.configuration_management = ""
			om_info.continuous_improvement = ""
			om_info.integration_v_and_v = ""
			om_info.measurement_process_and_qm = ""
			om_info.monitoring_and_control = ""
			om_info.project_justification = ""
			om_info.pp_scoping_and_structuring = ""
			om_info.risk_and_opportunities_management = ""
			om_info.run_mode_preparation = ""
			om_info.solution_definition = ""
			om_info.subcontracting_management = ""
			om_info.risks_management = ""
			om_info.planning = ""
			om_info.organisation = ""
			om_info.project_configuration = ""
			om_info.needs_management = ""
			om_info.tests_managements = ""
			om_info.product_configuration = ""
			om_info.technical = ""
			om_info.architecture = ""
			om_info.integration = ""
			om_info.alert = ""

			@om << om_info
		end

		if @om.count > 0
	        begin
	          @xml = Builder::XmlMarkup.new(:indent => 1)

	          headers['Content-Type']         = "application/vnd.ms-excel"
	          headers['Content-Disposition']  = 'attachment; filename="E-M&T_Ref_&_OM_adherence_KPI Data_Adherence.xls"'
	          headers['Cache-Control']        = ''
	          render "om_adherence.erb", :layout=>false
	        rescue Exception => e
	          render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
	    end

	end

end