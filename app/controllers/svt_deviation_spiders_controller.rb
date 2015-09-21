require 'spreadsheet'
class SvtDeviationSpidersController < ApplicationController
	layout "spider"

	ExportCustomization = Struct.new(:activity, :name, :status, :justification)
	Consolidation = Struct.new(:conso_id, :spider_id, :deliverable, :activity, :score, :justification)
	Consolidation_export = Struct.new(:conso_id, :spider_id, :deliverable, :activity, :score, :justification, :status)
	Devia_status_saved = Struct.new(:deliverable_id, :status_number)
	Customization_deliverable_status = Struct.new(:deliverable_name, :status_number)
	Maturity = Struct.new(:name, :percent)
	SPIDER_CONSO_AQ = 1
	SPIDER_CONSO_COUNTER = 2
	# 
	# INTERFACES
	# 
	def index
	    milestone_id 	 = params[:milestone_id]
	    empty			 = params[:empty]
	    if empty
	    	@empty = "<br/><strong>Please answer all questions before to consolidate</strong>"
	    end
	    @meta_activity_id = params[:meta_activity_id]
	    if @meta_activity_id == nil
	    	@meta_activity = SvtDeviationMetaActivity.find(:first)
	    	@meta_activity_id = @meta_activity.id
	    else
	    	@meta_activity = SvtDeviationMetaActivity.find(:first, :conditions=>["id = ?", @meta_activity_id])
	    end
	    @meta_activities = SvtDeviationMetaActivity.find(:all, :conditions=>["is_active = ?", true]).map { |ma| [ma.name, ma.id] }

	    if milestone_id
		    @milestone 	 = Milestone.find(:first, :conditions=>["id = ?", milestone_id])
		    @project 	 = Project.find(:first, :conditions=>["id = ?", @milestone.project_id])

		    @show_bilan_custo = get_show_bilan_custo(@milestone)
		    
	   		@last_spider = SvtDeviationSpider.last(:conditions => ["milestone_id= ?", milestone_id])
	   		if @last_spider
	   			@pie_chart = @last_spider.generate_pie_chart.to_url
	   		end

	    	# If spider currently edited
	    	if (@last_spider)
	    		if @last_spider.svt_deviation_spider_consolidations.count == 0
			    	generate_current_table(@last_spider, @meta_activity_id)
			    	check_meta_activities(@last_spider.id, @meta_activities)

			    	conso_temp = SvtDeviationSpiderConsolidationTemp.find(:first, :conditions=>["svt_deviation_spider_id = ?", @last_spider.id])
			    	if !conso_temp
				    	deviation_spider_temp_init = SvtDeviationSpiderConsolidationTemp.new
				    	deviation_spider_temp_init.svt_deviation_spider_id = @last_spider.id
				    	deviation_spider_temp_init.save
				    end
		    	end
		    	generate_spider_history(@milestone)

		    	@warning_psu_imported = compare_last_import_date_with_spider_creation_date(@last_spider)
	    	end
	    else
	    	redirect_to :controller=>:projects, :action=>:show, :id=>@project.id
	    end
	end

	def compare_last_import_date_with_spider_creation_date(spider)
		var = nil
		if spider
			import_date = get_last_import_date(spider.milestone.project_id)
			spider_creation_date = spider.created_at
			if import_date and spider_creation_date < import_date
				var = "This spider has been created before last PSU Import, please delete it and create a new one if necessary."
			end
		end

		return var
	end

	def get_last_import_date(project_id)
		var = nil
		var = SvtDeviationSpiderReference.find(:first, :conditions=>["project_id = ?", project_id], :order=>"version_number desc")
		if var
			var = var.created_at
		end

		return var
	end

	def index_history
	    deviation_spider_id = params[:deviation_spider_id]
	    @meta_activity_id 	= params[:meta_activity_id]
    	if @meta_activity_id == nil
	    	@meta_activity = SvtDeviationMetaActivity.find(:first)
	    	@meta_activity_id = @meta_activity.id
	    else
	    	@meta_activity = SvtDeviationMetaActivity.find(:first, :conditions=>["id = ?", @meta_activity_id])
	    end
	    @meta_activities = SvtDeviationMetaActivity.all.map { |ma| [ma.name, ma.id] }

	    if deviation_spider_id
	   		@last_spider = SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
		    @milestone = Milestone.find(:first, :conditions=>["id = ?", @last_spider.milestone_id])
		    @project = Project.find(:first, :conditions=>["id = ?", @milestone.project_id])
			generate_current_table(@last_spider,@meta_activity_id)
			if @last_spider
	   			@pie_chart = @last_spider.generate_pie_chart.to_url
	   		end
	    else
	    	redirect_to :controller=>:projects, :action=>:show, :id=>@project.id
	    end
	end

	def index_export_all
		#@projects = params[:projects]
		@projects = Project.find(:all, :conditions=>["supervisor_id = ? and name IS NOT NULL", 21])
	end

	def update_spider_file_name_form
	    spider_id  = params[:id]
	    @spider    = SvtDeviationSpider.find(spider_id)
  	end

  	def update_spider_file_name
	    spider_id          = params[:id]
	    if params[:svt_deviation_spider][:file_link]
	      spider           = SvtDeviationSpider.find(spider_id)
	      spider.file_link = params[:svt_deviation_spider][:file_link]
	      spider.save
	    end
	    redirect_to :controller=>:tools ,:action=>:show_counter_history
	end

	# --------
	# EXPORT
	# --------
	def export_customization_excel
		@custo_array = Array.new
		for i in 0..3 do
			@custo_array[i] = 0
		end
		customization_status_array = Array.new

		project_id = params[:project_id]
		@milestone_name = params[:milestone_name]
		@project = Project.find(:first, :conditions => ["id = ?", project_id])
		if @project
			begin
				@xml = Builder::XmlMarkup.new(:indent => 1)

				deviation_spider_reference_last = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order => "version_number")
				@exportCustomizations = Array.new
				# DeliverablesSettings: for each deliverable setting
				deviationSpiderSettings = SvtDeviationSpiderSetting.find(:all, :conditions => ["svt_deviation_spider_reference_id = ?", deviation_spider_reference_last]).each do |devia_settings|
					exportCustomization = ExportCustomization.new
					exportCustomization.activity = devia_settings.activity_name
					exportCustomization.name = devia_settings.deliverable_name
					exportCustomization.status = get_customization_deliverable_status(devia_settings.answer_1, devia_settings.answer_2, devia_settings.answer_3)
					exportCustomization.justification = devia_settings.justification
					@exportCustomizations << exportCustomization
					@custo_array, customization_status_array = get_customization_deliverable_status_array(devia_settings.deliverable_name, exportCustomization.status, @custo_array, customization_status_array)
				end
				lifecycle = Lifecycle.find(:first, :conditions=>["id = ?", @project.lifecycle_id])
				filename = @project.name+"_"+lifecycle.name+"_PSU_CustomizationDeviationMeasurement_Spiders_v1.0.xls"

				headers['Content-Type']         = "application/vnd.ms-excel"
		        headers['Content-Disposition']  = 'attachment; filename="'+filename+'"'
		        headers['Cache-Control']        = ''
		        render "custo.erb", :layout=>false
	        rescue Exception => e
	        	render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
		end
	end

	def export_customization_all
		projects_id = params[:projects_id]
		filter = params[:filter]
		if projects_id
			begin
				@xml = Builder::XmlMarkup.new(:indent => 1)

				@projects = Array.new

				projects_id.each do |id|
					project = Project.find(:first, :conditions=>["id = ?", id])
					@projects << project
				end

				filename = "CustomizationDeviationMeasurement_"+filter+"_v1.0.xls"

				headers['Content-Type']         = "application/vnd.ms-excel"
		        headers['Content-Disposition']  = 'attachment; filename="'+filename+'"'
		        headers['Cache-Control']        = ''
		        render "custo_all.erb", :layout=>false
	        rescue Exception => e
	        	render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
	    end
	end

	def get_customization_deliverable_status(answer_1, answer_2, answer_3)
		status = ""
		case answer_1
		when "Yes"
			status = "Project plans to use referential template to produce the deliverable"
		when "No"
			case answer_2
			when "No"
				status = "Project doesn't plan to produce deliverable without justification"
			when "Yes"
				case answer_3
				when "Deliverable N.A"
					status = "Deliverable not applicable to the project"
				when "Another template is used"
					status = "Project plans to use a different template from the referential one to produce the deliverable"
				else
					status = ""
				end
			else
				status = ""
			end
		else
			status = ""
		end

		return status
	end

	def get_customization_deliverable_status_array(deliverable_name, status, custo_array, customization_status_array)
		#:deliverable_name, :status_number
		customization_deliverable_status = Customization_deliverable_status.new
		status_number = nil
		already_added = false

		case status
		when "Project plans to use referential template to produce the deliverable"
			status_number = 0
		when "Deliverable not applicable to the project"
			status_number = 1
		when "Project plans to use a different template from the referential one to produce the deliverable"
			status_number = 2
		when "Project doesn't plan to produce deliverable without justification"
			status_number = 3
		end

		if status_number
			customization_deliverable_status.deliverable_name = deliverable_name
			customization_deliverable_status.status_number = status_number

			customization_status_array.each do |customization_status|
				if customization_status.deliverable_name == deliverable_name
					if status_number < customization_status.status_number
						customization_status_array.delete(customization_status)
						customization_status_array.push(customization_deliverable_status)
						custo_array[customization_status.status_number] = custo_array[customization_status.status_number] - 1
						custo_array[status_number] = custo_array[status_number] + 1
					end
					already_added = true
				end
			end

			if !already_added
				custo_array[status_number] = custo_array[status_number] + 1
				customization_status_array.push(customization_deliverable_status)
			end
		end
		
		return custo_array, customization_status_array
	end

	def consolidate_interface
	    deviation_spider_id = params[:deviation_spider_id]
	    if deviation_spider_id
	    	@deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])

	    	redirect = false
		    SvtDeviationSpiderDeliverable.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider_id]).each do |deliverable|
		    	SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ?", deliverable]).each do |value|
		    		if value.answer == nil
		    			redirect = true
		    		end
		    	end
		    end

		    if redirect
		    	redirect_to('/svt_deviation_spiders?milestone_id='+@deviation_spider.milestone_id.to_s+'&empty=1')
			end

		    @editable = params[:editable]
		    if @editable == nil
		    	@editable = false
		    end

	    	@score_list = [0,1,2,3]
	    	@all_meta_activities = SvtDeviationMetaActivity.find(:all, :conditions=>["is_active = ?", true])
	    	@all_activities 	= SvtDeviationActivity.find(:all, :conditions=>["is_active = ?", true])
	    	parameters = @deviation_spider.get_parameters
	    	@deliverables 		= Array.new
	    	@deviation_spider.svt_deviation_spider_deliverables.all(
	    	    :joins =>["JOIN svt_deviation_deliverables ON svt_deviation_spider_deliverables.svt_deviation_deliverable_id = svt_deviation_deliverables.id"],
	    	    :conditions => ["svt_deviation_deliverables.is_active = ?", true], 
	    	    :order => ["svt_deviation_deliverables.name"]).each do |spider_deliverable|
	    		@deliverables << spider_deliverable.svt_deviation_deliverable
	    	end

	    	@consolidations = get_consolidations(@deviation_spider, @all_activities, @deliverables, parameters, @editable, false)

			@maturity = @deviation_spider.get_deviation_maturity

			#get all svt deviation spiders linked to this project
			deviation_spiders = Array.new
			deviation_spiders = get_svt_deviation_spiders(@deviation_spider)
			@maturities, @maturities_name = get_maturities(deviation_spiders)

	    else
	    	redirect_to :controller=>:projects, :action=>:index
	    end
	end

	def get_svt_deviation_spiders(deviation_spider)
		spiders = Array.new
		SvtDeviationSpider.find(:all, :conditions=>["project_id = ?", deviation_spider.project_id], :order=>"id asc").each do |devia_spider|
			spiders << devia_spider
		end

		return spiders
	end

	def get_maturities(deviation_spiders)
		maturities = Array.new
		maturities_name = Array.new
		mat = Maturity.new # Maturity = Struct.new(:name, :percent)
		if deviation_spiders.count > 0
			deviation_spiders.each do |ds|
				if ds.milestone.done == 1
					maturities << ds.get_deviation_maturity
					maturities_name << ds.milestone.name
				end
			end
		end

		return maturities, maturities_name
	end

	def get_consolidations(deviation_spider, all_activities, deliverables, parameters, editable, export)
		consolidations = Array.new
		devia_status_saved_array = Array.new
		@status_array = Array.new
		for i in 0..9 do
			@status_array[i] = 0
		end

		all_activities.each do |activity|
    		deliverables.each do |deliverable|
    			deviation_deliverable_added_by_hand = SvtDeviationSpiderDeliverable.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and is_added_by_hand = ?", deviation_spider.id, deliverable.id, true])
    			is_applicable_added_by_hand = existing_question_activity_deliverable(deliverable.id, activity.id, deviation_spider.milestone)
    			if (self.get_deliverable_activity_applicable(deviation_spider.milestone.project_id, deliverable, activity, deviation_spider.milestone, parameters.psu_imported) or (deviation_deliverable_added_by_hand and is_applicable_added_by_hand))
					consolidation_saved = SvtDeviationSpiderConsolidationTemp.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ?", deviation_spider.id, deliverable.id, activity.id])
					if !consolidation_saved and editable
						#Consolidation in a temp table for manipulations before the real consolidation
	    				consolidation_temp = SvtDeviationSpiderConsolidationTemp.new
	    				consolidation_temp.svt_deviation_spider_id = deviation_spider.id
	    				consolidation_temp.svt_deviation_deliverable_id = deliverable.id
	    				consolidation_temp.svt_deviation_activity_id = activity.id
	    				consolidation_temp.score = self.get_score(deviation_spider.id, deliverable, activity)
	    				consolidation_temp.justification = self.get_justification(deviation_spider.id, deliverable, activity, consolidation_temp.score)

	    				consolidation_temp.save
    					consolidation_saved = consolidation_temp
					elsif !consolidation_saved and !editable
    					#We consult the tab consolidation instead of the temporary one
    					consolidation_saved = SvtDeviationSpiderConsolidation.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ?", deviation_spider.id, deliverable.id, activity.id])
    				end

    				if export == false
	    				consolidation = Consolidation.new
	    			elsif export == true
	    				consolidation = Consolidation_export.new
	    				consolidation.status = get_deviation_status(deviation_spider, deliverable, activity, consolidation_saved.score)
	    				@status_array, devia_status_saved_array = get_deviation_status_total(deviation_spider, deliverable, consolidation_saved.score, @status_array, devia_status_saved_array)
	    			end
    				consolidation.conso_id = consolidation_saved.id
    				consolidation.spider_id = consolidation_saved.svt_deviation_spider_id
    				consolidation.deliverable = SvtDeviationDeliverable.find(:first, :conditions => ["id = ?", consolidation_saved.svt_deviation_deliverable_id])
    				consolidation.activity = SvtDeviationActivity.find(:first, :conditions => ["id = ?", consolidation_saved.svt_deviation_activity_id])
    				consolidation.score = consolidation_saved.score
    				consolidation.justification = consolidation_saved.justification
    				
    				consolidations << consolidation
    			end
    		end
    	end
    	@status_array[0] = @status_array[6] + @status_array[7] + @status_array[8] + @status_array[9]
    	@status_array[5] = @status_array[1] + @status_array[2] + @status_array[3] + @status_array[4]
    	consolidations = consolidations & consolidations
    	return consolidations
	end

	def get_deviation_status(deviation_spider, deliverable, activity, score)
		status = weight = weight_temp = nil
		last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", deviation_spider.milestone.project_id], :order => "version_number asc")
		SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name]).each do |setting|
			if setting.answer_1 == "Yes" or setting.answer_3 == "Another template is used"
				case score
				when 0
					weight_temp = 4
				when 1
					weight_temp = 5
				when 2
					weight_temp = 6
				when 3
					weight_temp = 7
				end
			elsif setting.answer_1 != "Yes" and setting.answer_3 != "Another template is used"
				case score
				when 0
					weight_temp = 0
				when 1
					weight_temp = 1
				when 2
					weight_temp = 2
				when 3
					weight_temp = 3
				end
			end

			if weight
				if weight_temp and (weight_temp > weight)
					weight = weight_temp
				end
			else
				weight = weight_temp
			end
		end

		if !weight
			case score
			when 0
				weight = 0
			when 1
				weight = 1
			when 2
				weight = 2
			when 3
				weight = 3
			end
		end

		case weight
		when 0
			status = "Deliverable not expected \n -- \n Project did not produce the deliverable and it was not justified"
		when 1
			status = "Deliverable not expected \n -- \n Project did not produce the deliverable and it was justified"
		when 2
			status = "Deliverable not expected \n -- \n Project did produce the deliverable using a different template from the referential one"
		when 3
			status = "Deliverable not expected \n -- \n Project did produce the deliverable using the referential template"
		when 4
			status = "Deliverable expected \n -- \n Project did not produce Deliverable without appropriate justification"
		when 5
			status = "Deliverable expected \n -- \n Project did not produce Deliverable with appropriate justification"
		when 6
			status = "Deliverable expected \n -- \n Project produced Deliverable using a different template from the referential one"
		when 7
			status = "Deliverable expected \n -- \n Project produced Deliverable with the expected template"
		end

		return status
	end

	def get_deviation_status_total(deviation_spider, deliverable, score, status_array, devia_status_saved_array)
		setting_found = 0
		#:deliverable_id, :status_number
		devia_status_saved = Devia_status_saved.new

		last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", deviation_spider.milestone.project_id], :order => "version_number asc")
		SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ?", last_reference, deliverable.name]).each do |setting|
			not_to_add = false
			status_number = nil
			if setting.answer_1 == "Yes" or setting.answer_3 == "Another template is used"
				case score
				when 0
					status_number = 6
				when 1
					status_number = 7
				when 2
					status_number = 8
				when 3
					status_number = 9
				end
			elsif setting.answer_1 != "Yes" and setting.answer_3 != "Another template is used"
				case score
				when 0
					status_number = 1
				when 1
					status_number = 2
				when 2
					status_number = 3
				when 3
					status_number = 4
				end
			end

			if status_number
				setting_found = 1

				devia_status_saved_array.each do |devia_status|
					if devia_status.deliverable_id == deliverable.id
						if devia_status.status_number < status_number
							status_array[devia_status.status_number] = status_array[devia_status.status_number] - 1
							status_array[status_number] = status_array[status_number] + 1
							devia_status.status_number = status_number
						end
						not_to_add = true
					end
				end

				if !not_to_add
					status_array[status_number] = status_array[status_number] + 1
					devia_status_saved.deliverable_id = deliverable.id
					devia_status_saved.status_number = status_number
					devia_status_saved_array.push(devia_status_saved)
				end
			end
		end

		if setting_found == 0
			not_to_add = false
			case score
			when 0
				status_number = 1
			when 1
				status_number = 2
			when 2
				status_number = 3
			when 3
				status_number = 4
			end
			
			if status_number
				setting_found = 1

				devia_status_saved_array.each do |devia_status|
					if devia_status.deliverable_id == deliverable.id
						if devia_status.status_number < status_number
							status_array[devia_status.status_number] = status_array[devia_status.status_number] - 1
							status_array[status_number] = status_array[status_number] + 1
							devia_status.status_number = status_number
						end
						not_to_add = true
					end
				end

				if !not_to_add
					status_array[status_number] = status_array[status_number] + 1
					devia_status_saved.deliverable_id = deliverable.id
					devia_status_saved.status_number = status_number
					devia_status_saved_array.push(devia_status_saved)
				end
			end
		end

		return status_array, devia_status_saved_array
	end

	def export_deviation_excel
		project_id = params[:project_id]
		deviation_spider_id = params[:deviation_spider_id]
		@milestone_name = params[:milestone_name]

		all_activities 	= SvtDeviationActivity.find(:all, :conditions=>["is_active = ?", true])
		deviation_spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
    	parameters = deviation_spider.get_parameters
    	deliverables 		= Array.new
    	deviation_spider.svt_deviation_spider_deliverables.all(
    	    :joins =>["JOIN svt_deviation_deliverables ON svt_deviation_spider_deliverables.svt_deviation_deliverable_id = svt_deviation_deliverables.id"],
    	    :conditions => ["svt_deviation_deliverables.is_active = ?", true], 
    	    :order => ["svt_deviation_deliverables.name"]).each do |spider_deliverable|
    		deliverables << spider_deliverable.svt_deviation_deliverable
    	end

		@project = Project.find(:first, :conditions => ["id = ?", project_id])
		if @project
			begin
				@xml = Builder::XmlMarkup.new(:indent => 1)

				@lifecycle = Lifecycle.find(:first, :conditions=>["id = ?", @project.lifecycle_id])
				filename = @project.name+"_"+@lifecycle.name+"_DeviationMeasurement_Spiders_v1.0.xls"

				@first_milestone_name = ""
				if @lifecycle.id == 4 or @lifecycle.id == 5 or @lifecycle.id == 6 or @lifecycle.id == 9
					@first_milestone_name = "G2"
				else
					@first_milestone_name = "M3"
				end

				@consolidations = Consolidation_export.new
				@consolidations = get_consolidations(deviation_spider, all_activities, deliverables, parameters, true, true)

				headers['Content-Type']         = "application/vnd.ms-excel"
		        headers['Content-Disposition']  = 'attachment; filename="'+filename+'"'
		        headers['Cache-Control']        = ''
		        render "devia.erb", :layout=>false
			rescue Exception => e
	        	render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
		end
	end

	def get_deliverable_activity_applicable(project_id, deliverable, activity, milestone, psu_imported=true)
		applicable = false
		if psu_imported
			last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order => "version_number asc")
			SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name]).each do |setting|
				if (setting and (setting.answer_1 == "Yes" or setting.answer_3 == "Another template is used"))
					applicable = self.existing_question_activity_deliverable(deliverable.id, activity.id, milestone)
				end
			end
		else
			applicable = self.existing_question_activity_deliverable(deliverable.id, activity.id, milestone)
		end
		return applicable					
	end

	def get_score(deviation_spider_id, deliverable, activity)
		score = 0

		spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
		last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", spider.milestone.project_id], :order => "version_number asc")
		if last_reference
			setting = SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name])

			well_used = get_deliverable_is_well_used(deviation_spider_id, deliverable, activity)

			if setting and setting.count == 1 and setting[0].answer_1 == "Yes" and well_used
				score = 3
			elsif setting and setting.count == 1 and setting[0].answer_3 == "Another template is used" and well_used
				score = 2
			elsif setting and setting.count > 1
				setting.each do |sett|
					if sett.answer_1 == "Yes" and well_used
						score = 3
					elsif sett.answer_3 == "Another template is used" and well_used
						score = 2
					end
				end
			end
		end

		return score
	end

	def get_justification(deviation_spider_id, deliverable, activity, score)
		justification = nil
		
		spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])

		last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", spider.milestone.project_id], :order => "version_number asc")
		if last_reference
			setting = SvtDeviationSpiderSetting.find(:first, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name])

			well_used = get_deliverable_is_well_used(deviation_spider_id, deliverable, activity)

			if (setting and (setting.answer_1 == "Yes" or (setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used")) and well_used)
				justification = setting.justification
			end
		end

		project_id = spider.milestone.project_id
		Milestone.find(:all, :conditions=>["project_id = ?", project_id], :order=>"id desc").each do |milestone|
			spiders = SvtDeviationSpider.find(:all, :conditions=>["milestone_id = ?", milestone.id], :order=>"id desc").each do |spider|
				consolidation = SvtDeviationSpiderConsolidation.find(:first, :conditions=>["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ?", spider.id, deliverable.id, activity.id], :order=>"id desc")
				if consolidation and consolidation.justification and consolidation.justification != ""
					justification = consolidation.justification
				end
			end
		end

		return justification
	end

	def get_deliverable_is_well_used(deviation_spider_id, deliverable, activity)
		well_used = false
		deviation_deliverable = SvtDeviationSpiderDeliverable.find(:first, :conditions=>["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and not_done = ?", deviation_spider_id, deliverable.id, 0])
		if deviation_deliverable
			SvtDeviationQuestion.find(:all, :conditions=>["svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ?", deliverable.id, activity.id]).each do |question|
				deviation_value = SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ? and svt_deviation_question_id = ?", deviation_deliverable.id, question.id]).each do |value|
					if value.answer
						well_used = true
					end
				end
			end
		end

		return well_used
	end

	def existing_question_activity_deliverable(deliverable_id, activity_id, milestone)
		applicable = false
		milestone_name_id = MilestoneName.find(:first, :conditions=>["title = ?", milestone.name])
		SvtDeviationQuestion.find(:all, :conditions => ["svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ? and is_active = ?", deliverable_id, activity_id, true]).each do |question|
			question_milestone = SvtDeviationQuestionMilestoneName.find(:first, :conditions=>["svt_deviation_question_id = ? and milestone_name_id = ?", question.id, milestone_name_id])
			if question_milestone
				applicable = true
			end
		end
		return applicable
	end

	def update_score
		deviation_spider_consolidation_temp_id 		= params[:deviation_spider_consolidation_temp_id]
		deviation_spider_consolidation_temp_score 	= params[:deviation_spider_consolidation_temp_score]
		if deviation_spider_consolidation_temp_id and deviation_spider_consolidation_temp_score
			deviation_spider_consolidation_temp = SvtDeviationSpiderConsolidationTemp.find(:first, :conditions => ["id = ?", deviation_spider_consolidation_temp_id])
			deviation_spider_consolidation_temp.score = deviation_spider_consolidation_temp_score
			deviation_spider_consolidation_temp.justification = ""
			deviation_spider_consolidation_temp.save
		end
		render(:nothing=>true)
	end

	def update_justification
		deviation_spider_consolidation_temp_id 				= params[:deviation_spider_consolidation_temp_id]
		deviation_spider_consolidation_temp_justification 	= params[:deviation_spider_consolidation_temp_justification]
		if deviation_spider_consolidation_temp_id and deviation_spider_consolidation_temp_justification
			deviation_spider_consolidation_temp 			= SvtDeviationSpiderConsolidationTemp.find(:first, :conditions => ["id = ?", deviation_spider_consolidation_temp_id])
			deviation_spider_consolidation_temp.justification = deviation_spider_consolidation_temp_justification
			deviation_spider_consolidation_temp.save
		end
		render(:nothing=>true)
	end

	def consolidate_validation
		deviation_spider_id = params[:deviation_spider_id]
		@deviation_spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
		@project = @deviation_spider.milestone.project
	end

	def consolidate
		deviation_spider_id = params[:deviation_spider_id]
		list_choice = params[:list_choice]

		if deviation_spider_id
			# General data
			deviation_spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
	    	# Create consolidations if this is not already done
	    	if deviation_spider.svt_deviation_spider_consolidations.count == 0
				SvtDeviationSpiderConsolidationTemp.find(:all, :conditions => ["svt_deviation_spider_id = ?", deviation_spider_id]).each do |temp|
	    			new_deviation_spider_consolidation = SvtDeviationSpiderConsolidation.new
	    			new_deviation_spider_consolidation.svt_deviation_spider_id = temp.svt_deviation_spider_id
	    			new_deviation_spider_consolidation.svt_deviation_activity_id = temp.svt_deviation_activity_id
	    			new_deviation_spider_consolidation.svt_deviation_deliverable_id = temp.svt_deviation_deliverable_id
	    			new_deviation_spider_consolidation.score = temp.score
	    			new_deviation_spider_consolidation.justification = temp.justification
	    			new_deviation_spider_consolidation.save

	    			temp.delete
	    		end
		    end

		     # Increment the spider counter of the project
		    project = deviation_spider.milestone.project
		    
		    if((project) && (list_choice.to_i == SPIDER_CONSO_COUNTER.to_i))
		     	deviation_spider.impact_count = true;
			    deviation_spider.save

			    # Insert in history_counter
			    streamRef = Stream.find_with_workstream(project.workstream)
			    streamRef.set_spider_history_counter(current_user,deviation_spider)

			    # Increment counter
			    project.spider_count = project.spider_count + 1
			    project.save
		    end
		    redirect_to :controller=>:projects, :action=>:show, :id=>project.id
	    else
	    	redirect_to :action=>:consolidate_validation, :deviation_spider_id => deviation_spider_id, :error => 1
	    end
	end

	def delete_current_spider
	    deviation_spider_id = params[:deviation_spider_id]
    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    
    	if deviation_spider.svt_deviation_spider_consolidations.count == 0
    		SvtDeviationSpiderActivityValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |activityvalue|
    			activityvalue.delete
    		end
    		SvtDeviationSpiderDeliverableValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |deliverablevalue|
    			deliverablevalue.delete
    		end
    		SvtDeviationSpiderDeliverable.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |deliverable|
    			SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ?", deliverable.id]).each do |value|
    				value.delete
    			end
    			deliverable.delete
    		end
    		deviation_spider.delete
	    end
	    redirect_to :controller=>:projects, :action=>:show, :id=>deviation_spider.milestone.project.id
	end

	def delete_consolidated_spider
	    deviation_spider_id = params[:deviation_spider_id]
    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
    	if deviation_spider and deviation_spider.svt_deviation_spider_consolidations.count > 0
    		SvtDeviationSpiderActivityValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |activityvalue|
    			activityvalue.delete
    		end
    		SvtDeviationSpiderConsolidation.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |consolidation|
    			consolidation.delete
    		end
    		SvtDeviationSpiderDeliverableValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |deliverablevalue|
    			deliverablevalue.delete
    		end
    		SvtDeviationSpiderDeliverable.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |deliverable|
    			SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ?", deliverable.id]).each do |value|
    				value.delete
    			end
    			deliverable.delete
    		end
    		deviation_spider.delete
	    end
	    redirect_to :controller=>:projects, :action=>:show, :id=>deviation_spider.milestone.project.id
	end

	def create_spider_select_deliverables
		deviation_spider_id = params[:deviation_spider_id]
		if deviation_spider_id
	   		@deviation_spider = SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def get_deliverable_chart
		deviation_spider_id = params[:deviation_spider_id]
	    meta_activity_id 	= params[:meta_activity_id]

	    if deviation_spider_id and meta_activity_id
	    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	chart_data = deviation_spider.generate_deliverable_chart(meta_activity_id)
	    end

	    render(:text=>chart_data.to_json)
	end

	def get_activity_chart
		deviation_spider_id = params[:deviation_spider_id]
	    meta_activity_id 	= params[:meta_activity_id]

	    if deviation_spider_id and meta_activity_id
	    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	chart_data = deviation_spider.generate_activity_chart(meta_activity_id)
	    end

	    render(:text=>chart_data.to_json)
	end

	def get_deliverable_charts
		deviation_spider_id = params[:deviation_spider_id]

		charts = Array.new
	    if deviation_spider_id
	    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	charts = deviation_spider.generate_deliverable_charts
	    end

	    render(:text=>charts.to_json)
	end

	def get_activity_charts
		deviation_spider_id = params[:deviation_spider_id]
		
		charts = Array.new
	    if deviation_spider_id 
	    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	charts = deviation_spider.generate_activity_charts
	    end

	    render(:text=>charts.to_json)
	end

	def get_pie_chart(deviation_spider)
    	chart_data = deviation_spider.generate_pie_chart
	    return chart_data
	end

	# 
	# ACTIONS WITHOUT INTERFACE
	# 
	def create_spider
	    milestone_id 	= params[:milestone_id]
	    @milestone 	= Milestone.find(:first, :conditions=>["id = ?", milestone_id])  

		@deviation_project = nil
		if @milestone
			@deviation_spider = SvtDeviationSpider.new
			@deviation_spider.milestone_id = milestone_id
			@deviation_spider.project_id = @milestone.project_id
			@deviation_spider.save
			@deviation_spider.init_spider_data
			redirect_to :action =>:index, :milestone_id => milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def update_question
		deviation_spider_value_id = params[:deviation_spider_value_id]
		deviation_spider_value_answer = params[:deviation_spider_value_answer]
		deviation_spider_value = SvtDeviationSpiderValue.find(:first, :conditions => ["id = ?", deviation_spider_value_id])

		#when user select a 'yes' in a deliverable, button "all answer for the deliverable to no" becomes grey (not selected)
		if to_boolean(deviation_spider_value_answer)
			deviation_spider_value.svt_deviation_spider_deliverable.not_done = false
			deviation_spider_value.svt_deviation_spider_deliverable.save
		end

		if deviation_spider_value.answer == to_boolean(deviation_spider_value_answer)
			deviation_spider_value.answer = nil
		else
			deviation_spider_value.answer = to_boolean(deviation_spider_value_answer)
		end
		deviation_spider_value.save

		# Update other questions
		updated_spider_value_id = Array.new
		deviation_spider = deviation_spider_value.svt_deviation_spider_deliverable.svt_deviation_spider
		
		deviation_spider.svt_deviation_spider_deliverables.each do |deliverable|
			deliverable.svt_deviation_spider_values.each do |value|
				if deviation_spider_value.svt_deviation_spider_deliverable_id == value.svt_deviation_spider_deliverable_id and deviation_spider_value.svt_deviation_question.question_text == value.svt_deviation_question.question_text and value.id != deviation_spider_value.id
					updated_spider_value_id << value.id.to_s
					if value.answer == to_boolean(deviation_spider_value_answer)
						value.answer = nil
					else
						value.answer = to_boolean(deviation_spider_value_answer)
					end
					value.save
				end
			end
		end

		render(:text=>updated_spider_value_id.join(','))
	end

	def update_file_link
		deviation_spider_id = file_link = nil
		deviation_spider_id = params[:deviation_id]
		file_link 			= params[:file_link]
		redirect 			= params[:redirect]
		deviation_spider 	= SvtDeviationSpider.find(:last, :conditions=>["id = ?", deviation_spider_id], :order=>"id")

		if file_link != nil and deviation_spider != nil and file_link != ""
			deviation_spider.file_link = file_link
			deviation_spider.save
		end

		if redirect and redirect == "index_history"
			redirect_to :action=>:index_history, :deviation_spider_id=>deviation_spider.id
		else
			redirect_to :action=>:index, :milestone_id=>deviation_spider.milestone_id
		end
	end

	def delete_spider_deliverable
		deviation_spider_deliverable_id = params[:deviation_spider_deliverable_id]
		if deviation_spider_deliverable_id
			deviation_spider_deliverable = SvtDeviationSpiderDeliverable.find(:first, :conditions => ["id = ?", deviation_spider_deliverable_id])
			milestone_id = deviation_spider_deliverable.svt_deviation_spider.milestone_id
			deviation_spider_deliverable.destroy
			redirect_to :action=>:index, :milestone_id=>milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end


	def get_show_bilan_custo(milestone)
		show = false
		if milestone.name == "M1" or milestone.name == "M3" or milestone.name == "M5" or milestone.name == "M5/M7" or milestone.name == "G0" or milestone.name == "G2" or milestone.name == "G3" or milestone.name == "G4" or milestone.name == "G5" or milestone.name == "M5 Agile"
			show = true
		end
		return show
	end

	def add_spider_deliverable
		deviation_spider_id 			= params[:deviation_spider_id]
		deviation_deliverable_id 		= params[:deviation_deliverable_id]
		if deviation_spider_id and deviation_deliverable_id
			deviation_deliverable 		= SvtDeviationDeliverable.find(:first, :conditions => ["id = ?", deviation_deliverable_id])
			deviation_spider 			= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
			parameters 					= deviation_spider.get_parameters
			questions 					= deviation_spider.get_questions
			deviation_spider.add_deliverable(questions, deviation_deliverable, parameters.activities, parameters.psu_imported, true, false)
			redirect_to :action=>:index, :milestone_id=>deviation_spider.milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def set_false_for_spider_deliverable
		meta_activity_id = params[:meta_activity_id]
		deviation_spider_deliverable_id = params[:deviation_spider_deliverable_id]
		if deviation_spider_deliverable_id
			deviation_spider_deliverable = SvtDeviationSpiderDeliverable.find(:first, :conditions => ["id = ?", deviation_spider_deliverable_id])
			deviation_spider_deliverable.not_done = 1
			deviation_spider_deliverable.save
			deviation_spider_deliverable.svt_deviation_spider_values.each do |s|
				s.answer = 0
				s.save
			end

			redirect_to :action=>:index, :milestone_id=>deviation_spider_deliverable.svt_deviation_spider.milestone_id, :meta_activity_id=>meta_activity_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	# **
	# INTERNAL
	# **
	def generate_current_table(spider, meta_activity_id)
		@questions = SvtDeviationSpiderValue.find(:all, 
		:joins => ["JOIN svt_deviation_spider_deliverables ON svt_deviation_spider_deliverables.id = svt_deviation_spider_values.svt_deviation_spider_deliverable_id",
		"JOIN svt_deviation_questions ON svt_deviation_questions.id = svt_deviation_spider_values.svt_deviation_question_id",
		"JOIN svt_deviation_activities ON svt_deviation_activities.id = svt_deviation_questions.svt_deviation_activity_id",
		"JOIN svt_deviation_deliverables ON svt_deviation_deliverables.id = svt_deviation_spider_deliverables.svt_deviation_deliverable_id"], 
		:conditions => ["svt_deviation_spider_deliverables.svt_deviation_spider_id = ? and svt_deviation_activities.svt_deviation_meta_activity_id = ? and svt_deviation_deliverables.is_active = ? and svt_deviation_activities.is_active = ? and svt_deviation_questions.is_active = ?", spider.id, meta_activity_id, true, true, true], 
		:order => "svt_deviation_activities.name , svt_deviation_deliverables.name, svt_deviation_questions.question_text")

		#Search in the list of all deliverables for a milestone, if there is one which is not present in the current spider.
		last_reference 			= SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", spider.milestone.project_id], :order => "version_number asc")
		deliverable_ids 		= spider.svt_deviation_spider_deliverables.map {|d| d.svt_deviation_deliverable_id }
		deliverable_ids_cleaned = Array.new
		if last_reference
			#in deliverable_ids, we have all referenced deliverables, even if in the setting we say that we don't want it.
			deliverable_ids.each do |deliv|
				if supposed_to_be_added(spider.id, last_reference.id, deliv)
					deliverable_ids_cleaned << deliv
				end
			end
		else
			deliverable_ids_cleaned = deliverable_ids
		end

		deliverables_to_add = SvtDeviationDeliverable.find(:all, 
		                      :joins=>["JOIN svt_deviation_questions ON svt_deviation_questions.svt_deviation_deliverable_id = svt_deviation_deliverables.id", 
		                      	"JOIN svt_deviation_question_milestone_names ON svt_deviation_question_milestone_names.svt_deviation_question_id = svt_deviation_questions.id",
		                      	"JOIN milestone_names ON milestone_names.id = svt_deviation_question_milestone_names.milestone_name_id",
		                      	"JOIN svt_deviation_question_lifecycles ON svt_deviation_question_lifecycles.svt_deviation_question_id = svt_deviation_questions.id"], 
		                      	:conditions => ["svt_deviation_deliverables.id NOT IN (?) and svt_deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and svt_deviation_deliverables.is_active = ?", deliverable_ids_cleaned, spider.milestone.project.lifecycle_object.id, spider.milestone.name, true]).map { |d| [d.name, d.id]}
		@deliverables_to_add = deliverables_to_add & deliverables_to_add
	end

	#check if in the seetings we said that it shall be added
	def supposed_to_be_added(spider_id, last_reference_id, deliverable_id)
		to_add 				= false
		deliverable 		= SvtDeviationDeliverable.find(:first, :conditions => ["id = ? and is_active = ?", deliverable_id, true])
		if deliverable
			spider_deliverable 	= SvtDeviationSpiderDeliverable.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ?", spider_id, deliverable_id])
			settings 			= SvtDeviationSpiderSetting.find(:all, :conditions => ["svt_deviation_spider_reference_id = ? and deliverable_name = ?", last_reference_id, deliverable.name])
			if settings
				settings.each do |setting|
					if (setting.answer_1 == "Yes" or (setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used"))
						to_add = true
					end
				end
			end
		end

		if spider_deliverable and spider_deliverable.is_added_by_hand
			to_add = true
		end

		return to_add
	end

	def check_meta_activities(spider_id, meta_activities)
		new_meta_activities_array = Array.new
		meta_activities.each do |meta_activity|
			questions_nil_count = SvtDeviationSpiderValue.count(
			    :joins => ["JOIN svt_deviation_spider_deliverables ON svt_deviation_spider_deliverables.id = svt_deviation_spider_values.svt_deviation_spider_deliverable_id",
				"JOIN svt_deviation_questions ON svt_deviation_questions.id = svt_deviation_spider_values.svt_deviation_question_id",
				"JOIN svt_deviation_activities ON svt_deviation_activities.id = svt_deviation_questions.svt_deviation_activity_id"],
				:conditions => ["svt_deviation_spider_values.answer IS NULL and svt_deviation_activities.svt_deviation_meta_activity_id = ? and svt_deviation_spider_deliverables.svt_deviation_spider_id = ?", meta_activity[1], spider_id])

			if questions_nil_count > 0
				meta_activity_array = Array.new
				meta_activity_array << meta_activity[0]+" [Not filled in]"
				meta_activity_array << meta_activity[1]
				new_meta_activities_array << meta_activity_array
			else 
				new_meta_activities_array << meta_activity
			end
		end
		@meta_activities = new_meta_activities_array
	end

	def generate_spider_history(milestone)
		@history = Array.new
		SvtDeviationSpider.find(:all,
		    :select => "DISTINCT(svt_deviation_spiders.id),svt_deviation_spiders.created_at",
    		:joins => 'JOIN svt_deviation_spider_consolidations ON svt_deviation_spiders.id = svt_deviation_spider_consolidations.svt_deviation_spider_id',
    		:conditions => ["milestone_id= ?", milestone.id]).each { |s| @history.push(s) }
	end


	def to_boolean(str)
      str == 'true'
    end
end
