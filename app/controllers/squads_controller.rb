class SquadsController < ApplicationController

  def index

  	#Select and show squads
  	if params[:squad]
  		@current_squad = Squad.find(:first, :conditions=>["id = ?", params[:squad]])
  	end
  	@squads = Array.new
  	 PersonSquad.find(:all, :conditions=>["person_id = ?", current_user.id], :order=> "squad_id").each do |person_squad|
  	 	squad = Squad.find(:first, :conditions=>["id = ?", person_squad.squad_id])
  	 	if squad
  	 		if !params[:squad]
  	 			@current_squad = squad
  	 		end
  	 		#@squads << squad
  	 	end
  	end
    @squads = Squad.all

  	#Get current squad informations
  	@persons = Array.new
    if !@current_squad
      @current_squad = Squad.first
    end
  	PersonSquad.find(:all, :conditions=>["squad_id = ?", @current_squad.id]).each do |person_squad|
      person = Person.find(:first, :conditions=>["id = ?", person_squad.person_id])
      if person and person.is_transverse == 0 and person.has_left == 0
  		  @persons << person
      end
  	end

  	#PDC view
    @workloads = Array.new
    @totals_5_weeks = Array.new
    @cap_totals_5_weeks = Array.new
    @totals_3_months = Array.new
    @cap_totals_3_months = Array.new
    @avail_totals = Array.new

    for p in @persons
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
    @cap_totals_5_weeks << (@workloads.inject(0) { |sum,w| sum += cap(w.next_month_percents)} / size).round
    # next 3 months
    @totals_3_months << (@workloads.inject(0) { |sum,w| sum += w.three_next_months_percents} / size).round
    @cap_totals_3_months << (@workloads.inject(0) { |sum,w| sum += cap(w.three_next_months_percents)} / size).round
    # next 8 weeks
    @avail_totals << (@workloads.inject(0) { |sum,w| sum += w.sum_availability })

  end

  def cap(nb)
    nb > 100 ? 100 : nb
  end

end