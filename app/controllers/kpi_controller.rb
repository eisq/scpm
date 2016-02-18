require 'spreadsheet'

class KpiController < ApplicationController

	layout 'tools'
  	include WelcomeHelper

	Setting_info    = Struct.new(:lifecycle, :workstream, :plm, :activity_name, :deliverable_name, :plan_to_do)

	def index
	end

	def extract_list_deliverable
		@settings = Array.new

		DeviationSpiderSetting.find(:all).each do |setting|
			setting_info = Setting_info.new
			setting_info.lifecycle = setting.deviation_reference.project.lifecycle
			setting_info.workstream = setting.deviation_reference.project.workstream.name
			setting_info.plm = setting.deviation_reference.project.suite_tag.name
			setting_info.activity_name = setting.activity_name
			setting_info.deliverable_name = setting.deliverable_name
			setting_info.plan_to_do = setting.answer_1
			@settings << setting_info
		end

		SvtDeviationSpiderSetting.find(:all).each do |setting|
			setting_info = Setting_info.new
			setting_info.lifecycle = setting.deviation_reference.project.lifecycle
			setting_info.workstream = setting.deviation_reference.project.workstream.name
			setting_info.plm = setting.deviation_reference.project.suite_tag.name
			setting_info.activity_name = setting.activity_name
			setting_info.deliverable_name = setting.deliverable_name
			setting_info.plan_to_do = setting.answer_1
			@settings << setting_info
		end

		SvfDeviationSpiderSetting.find(:all).each do |setting|
			setting_info = Setting_info.new
			setting_info.lifecycle = setting.deviation_reference.project.lifecycle
			setting_info.workstream = setting.deviation_reference.project.workstream.name
			setting_info.plm = setting.deviation_reference.project.suite_tag.name
			setting_info.activity_name = setting.activity_name
			setting_info.deliverable_name = setting.deliverable_name
			setting_info.plan_to_do = setting.answer_1
			@settings << setting_info
		end

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

end