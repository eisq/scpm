class CiProjectLink < ActiveRecord::Base

	Link = Struct.new(:second_ci_project, :title, :second_ci_project_external_id)

	def self.get_links_title
		return ["", "Related to", "Dependant on", "Blocks"]
	end

	def self.get_links(ci_project_id)
		links = Array.new

		CiProjectLink.find(:all, :conditions=>["first_ci_project_id = ? or second_ci_project_id = ?", ci_project_id, ci_project_id]).each do |l|
			link = Link.new
			if l.first_ci_project_id == ci_project_id
				link.second_ci_project = l.second_ci_project_id
				link.title = l.title
				second_ci_project = CiProject.find(:first, :conditions=>["id = ?", link.second_ci_project])
				link.second_ci_project_external_id = CiProject.extract_mantis_external_id(second_ci_project.external_id)
			else
				link.second_ci_project = l.first_ci_project_id
				if l.title == "Blocks"
					link.title = "Dependant on"
				elsif l.title == "Dependant on"
					link.title = "Blocks"
				else
					link.title = l.title
				end
				second_ci_project = CiProject.find(:first, :conditions=>["id = ?", link.second_ci_project])
				link.second_ci_project_external_id = CiProject.extract_mantis_external_id(second_ci_project.external_id)
			end

			links << link
	    end

		return links
	end

end