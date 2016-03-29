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
  	 		@squads << squad
  	 	end
  	 end

  	#Get current squad informations
  	@persons = Array.new
  	PersonSquad.find(:all, :conditions=>["squad_id = ?", @current_squad.id]).each do |person_squad|
  		@persons << Person.find(:first, :conditions=>["id = ?", person_squad.person_id])
  	end



  	#PDC view


  end

end