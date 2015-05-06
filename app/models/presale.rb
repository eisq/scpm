class Presale < ActiveRecord::Base
  	belongs_to  :project
    has_many    :presale_presale_types, :dependent => :nullify


    PRIORITY_NONE = -1
    PRIORITY_TOO_LATE = 1
    PRIORITY_TO_BE_FOLLOWED = 2
    PRIORTY_IN_TIME = 3
    PRIORITY_URGENT = 4
    PRIORITY_VERY_URGENT = 5

    def next_milestone_date
        next_milestone = self.project.get_next_milestone    
        if next_milestone != nil and next_milestone.actual_milestone_date != nil and next_milestone.actual_milestone_date != ""
            return next_milestone.actual_milestone_date
        elsif next_milestone != nil and next_milestone.milestone_date != nil and next_milestone.milestone_date != ""
            return next_milestone.milestone_date
        else
            return nil
        end
    end

    def next_milestone
        return self.project.get_next_milestone
    end

    def Presale.init_with_project(project_id)
    	presale = Presale.new
    	presale.project_id = project_id
    	presale.save
        return presale
    end

    def Presale.get_priority_message(priority_raw)
    	case priority_raw
    	when PRIORITY_NONE
    		return "None"
    	when PRIORITY_TO_BE_FOLLOWED
    		return "To be followed"
    	when PRIORTY_IN_TIME
    		return "In time"
    	when PRIORITY_URGENT
    		return "Urgent"
    	when PRIORITY_VERY_URGENT
    		return "Very urgent"
    	when PRIORITY_TOO_LATE
    		return "Too late"
    	end
    	return "Unknow"
    end

    def Presale.get_color(priority_raw)get_next_milestone_column_background_color
        case priority_raw
        when PRIORITY_NONE
            return "#FFFFFF"
        when PRIORITY_TO_BE_FOLLOWED
            return "#CCF5FF"
        when PRIORTY_IN_TIME
            return "#BEFFD1"
        when PRIORITY_URGENT
            return "#FAC39E"
        when PRIORITY_VERY_URGENT
            return "#FD9191"
        when PRIORITY_TOO_LATE
            return "#A39C9C"
        end
        return "#FFFFFF"
    end
end
