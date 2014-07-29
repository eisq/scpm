class AddOrderToLifecycleMilestones < ActiveRecord::Migration
  def self.up
    add_column :lifecycle_milestones, :order, :integer
    
    Lifecycle.find(:all).each do |l|
        milestones_order = AddOrderToLifecycleMilestones.helper_create_milestones(l)
        if milestones_order
          l.lifecycle_milestones.each do |lm|
            order = milestones_order.index(lm.milestone_name.title)
            if order
              lm.order = order + 1
              lm.save
            end
          end
        end
    end
  end

  def self.down
    remove_column :lifecycle_milestones, :order
  end


  # Copy of the old system
  def self.helper_create_milestones(lifecycle)
    case lifecycle.name
        when "Full GPP"
          return ['M1', 'M3', 'QG BRD', 'QG ARD', 'M5', 'M7', 'M9', 'M10', 'QG TD', 'M10a', 'QG MIP', 'M11', 'M12', 'M13', 'M14']
        when "Light GPP"
          return ['M1', 'M3', 'QG BRD', 'QG ARD', 'M5/M7', 'M9/M10', 'QG TD', 'QG MIP', 'M11', 'M12/M13', 'M14']
        when "Maintenance"
          return ['CCB', 'QG TD M', 'MIPM']
        when "LBIP Gx"
          return ['G0', 'G2', 'G3', 'G4', 'QG BRD', 'G5', 'G6', 'G7', 'G8', 'G9']
        when "LBIP gx"
          return ['g0', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7', 'g8', 'g9']
        when "LBIP pgx"
          return ['pg0', 'pg2', 'pg3', 'pg4', 'pg5', 'pg6', 'pg7', 'pg8', 'pg9']
        when "Suite"
          return ['sM1', 'sM3', 'sM5', 'sM13', 'sM14']
        end
  end

end
