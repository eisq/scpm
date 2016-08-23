class SquadsController < ApplicationController

  Late_reporting = Struct.new(:person, :squad, :project, :delay)

  def index

    @squads = @current_squad = @persons = @not_in_workload = @late_reportings = nil

    @squads, @current_squad, @persons = init_squad_person

    view_pdc(@persons)
    @not_in_workload = view_not_in_workload(@current_squad)
    @tbvs = tbv_request_start_soon_view(@persons)
    view_holidays_backup
    late_reportings = view_late_reporting(@current_squad, @persons)
    @late_reportings = late_reportings.sort! { |a,b| b.delay <=> a.delay }

  end

  def init_squad_person
    #Select and show squads
    if params[:squad]
      current_squad = Squad.find(:first, :conditions=>["id = ?", params[:squad]])
    end
    squads = Array.new
     PersonSquad.find(:all, :conditions=>["person_id = ?", current_user.id], :order=> "squad_id").each do |person_squad|
      squad = Squad.find(:first, :conditions=>["id = ?", person_squad.squad_id])
      if squad
        if !params[:squad]
          @current_squad = squad
        end
        #@squads << squad
      end
    end
    squads = Squad.find(:all, :order => "name")

    #Get current squad informations
    persons = Array.new
    if !current_squad
      current_squad = Squad.first
    end
    PersonSquad.find(:all, :conditions=>["squad_id = ?", current_squad.id]).each do |person_squad|
      person = Person.find(:first, :conditions=>["id = ?", person_squad.person_id])
      if person and person.is_transverse == 0 and person.has_left == 0
        persons << person
      end
    end

    return squads, current_squad, persons
  end

  def view_pdc(persons)
    #PDC view
    @workloads = Array.new
    @totals_5_weeks = Array.new
    @cap_totals_5_weeks = Array.new
    @totals_3_months = Array.new
    @cap_totals_3_months = Array.new
    @avail_totals = Array.new

    for p in persons
      if APP_CONFIG['workloads_add_by_project']
        next if not p.has_workload_for_projects?(@project_ids)
      end
      w = Workload.new(p.id,[],'','', {:add_holidays=>true})
      next if w.wl_lines.select{|l| l.wl_type != WL_LINE_HOLIDAYS}.size == 0 # do not display people with no lines at all
      @workloads << w
    end
    @workloads = @workloads.sort_by {|w| [-w.person.is_virtual, w.next_month_percents, w.three_next_months_percents, w.person.name]}
    size = @workloads.size

    # next 5 weeks
    @totals_5_weeks << (@workloads.inject(0) { |sum,w| sum += w.next_month_percents} / size).round
    if @totals_5_weeks[0].to_i > 105
      @totals_color = "_red"
    elsif @totals_5_weeks[0].to_i < 90
      @totals_color = "_orange"
    else
      @totals_color = ""
    end
    @cap_totals_5_weeks << (@workloads.inject(0) { |sum,w| sum += cap(w.next_month_percents)} / size).round
    if @cap_totals_5_weeks[0].to_i > 105
      @cap_totals_color = "_red"
    elsif @cap_totals_5_weeks[0].to_i < 90
      @cap_totals_color = "_orange"
    else
      @cap_totals_color = ""
    end
    # next 3 months
    @totals_3_months << (@workloads.inject(0) { |sum,w| sum += w.three_next_months_percents} / size).round
    @cap_totals_3_months << (@workloads.inject(0) { |sum,w| sum += cap(w.three_next_months_percents)} / size).round
    # next 8 weeks
    @avail_totals << (@workloads.inject(0) { |sum,w| sum += w.sum_availability }).round
  end

  def view_not_in_workload(current_squad)
    #Tickets not in PDC view
    ###

    # comment : these queries are used in the consolidation view for "not in workload" tokens
    #already_in_the_workload = WlLine.all.select{|l| l.request and (l.request.status=='to be validated' or (l.request.status=='assigned' and l.request.resolution!='ended' and l.request.resolution!='aborted'))}.map{|l| l.request}
    #not_in_workload= (Request.find(:all,:conditions=>["status='to be validated' or (status='assigned' and resolution!='ended' and resolution!='aborted')"]) - already_in_the_workload).sort_by{|r| [r.status, (r.project ? r.project.full_name : "")]}.reverse

    not_in_workload = Array.new

    # If a squad is defined
    if current_squad

      #implement request when squad name is not usual
      if current_squad.name.to_s.length > 2
          case current_squad.name.to_s
            when "Squad Cathie" then squad_query = "workstream ='EI' or workstream='EV'"
            when "Squad Lucie"  then squad_query = "workstream ='ES' or workstream='EG'"
            when "Squad Fabrice" then squad_query = "workstream ='EY' or workstream='EC' or workstream='EP'"
            #when "PhD" then squad_query = "PhD" #Goto to *Get all requests for squad "phd"* Part (not used atm)
            when "PhD" then squad_query = "request_type = 'Yes'" #Is Physical = Yes
          else
            squad_query = "workstream ='" + current_squad.name + "'"
          end
      else
        squad_query = "workstream ='" + current_squad.name + "'"
      end

       #Get all requests for squad "phd", only request which is bound to a project with a suite_tag number (not used atm)
      if squad_query == 'PhD'
        # if @project.suite_tag
        Project.find(:all, :conditions=>["suite_tag_id >0"]).each do |project_row|
          Request.find(:all, :conditions=>["project_id= ?", project_row.id]).each do |request_phd|
            if request_phd
              if request_phd.status == 'to be validated' or (request_phd.status == 'assigned' and request_phd.resolution !='ended' and request_phd.resolution!='aborted')
                #Check the request, if exists in the orkload (i.e wline table)
                current_request = WlLine.find(:first, :conditions=>["request_id = ?", request_phd.request_id])
                if !current_request 
                  #If not get the request
                  not_in_workload << request_phd
                end
              end
            end
          end  
        end 

      else  

      #Get all requests for the current squad
        Request.find(:all, :conditions=>[squad_query]).each do |request_squad|
          if request_squad
            if request_squad.status == 'to be validated' or (request_squad.status == 'assigned' and request_squad.resolution !='ended' and request_squad.resolution!='aborted')
              #Check the request, if exists in the orkload (i.e wline table)
              current_request = WlLine.find(:first, :conditions=>["request_id = ?", request_squad.request_id])
              if !current_request 
                #If not get the request
                not_in_workload << request_squad
              end
            end
          end
        end
      end
    end

    ###
    return not_in_workload
  end

  def tbv_request_start_soon_view(persons)
    tbvs = Array.new

    persons.each do |person|
      tbvs << person.tbv_based_on_wl
    end

    return tbvs
  end

  def view_holidays_backup

  end

  def view_late_reporting(current_squad, persons)
    late_reportings = Array.new
    already_founds = Array.new
    request = ""

    persons.each do |person|
      # if the squad is PhD, the request will search about the tag suite_tag_id
      if current_squad.name == "PhD"
        request = "suite_tag_id IS NOT NULL"
      else
        request = "workstream = '#{current_squad.name}'"
      end

      Project.find(:all, :conditions=>[request + " and is_running = true and is_on_hold = false"]).each do |project|
        #Late_reporting.new(:person, :squad, :project, :delay)
        late_reporting = Late_reporting.new
        project_person = ProjectPerson.find(:first, :conditions => ["project_id = ? and person_id = ?", project.id, person.id])
        if project_person and project_person.person_id == person.id
          status = project.get_status
          date_last_update = status.updated_at
          if date_last_update
            last_update = get_date_from_bdd_date(date_last_update)
            delay = Date.today() - last_update
            if delay > 15
              to_add = true
              already_founds.each do |already_found|
                if project.id == already_found
                  to_add = false
                end
              end

              if to_add
                late_reporting.person = person
                late_reporting.squad = Squad.find(:first, :conditions=>["name = ?", project.workstream])
                late_reporting.project = project
                late_reporting.delay = delay
                late_reportings << late_reporting
                already_founds << late_reporting.project.id
              end
            end
          end
        end
      end
    end

    return late_reportings
  end

  def save_reporting
    if params[:reporting] != "" and params[:current_squad_id] != ""
      reporting = params[:reporting]
      squad_id = params[:current_squad_id].to_i

      squad = Squad.find(:first, :conditions=>["id = ?", squad_id])
      if squad
        squad.reporting = reporting
        squad.save
      end
    end

    redirect_to "/squads/index?squad=#{squad_id}"
  end

  def get_date_from_bdd_date(bdd_date)
    date_split = bdd_date.to_s.split("-")
    date = Date.new(date_split[0].to_i, date_split[1].to_i, date_split[2].to_i)

    return date
  end

  def cap(nb)
    nb > 100 ? 100 : nb
  end

end