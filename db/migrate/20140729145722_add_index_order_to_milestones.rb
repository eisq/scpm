class AddIndexOrderToMilestones < ActiveRecord::Migration
  def self.up
    add_column :milestones, :index_order, :integer
    
    Project.find(:all, :conditions=>["name IS NOT NULL"]).each do |p|
    	i = 1
    	AddIndexOrderToMilestones.helper_sorted_milestones(p).each do |m|
    		m.index_order = i
    		m.save
    		i += 1
    	end
    end
  end

  def self.down
    remove_column :milestones, :index_order
  end


  # Copy of the old system
  def self.helper_sorted_milestones(project)
    project.milestones.sort_by { |m| [AddIndexOrderToMilestones.helper_milestone_order(m.name), (m.date ? m.date : Date.today())]}
  end

  def self.helper_milestone_order(name)
    case name
    when 'M1';      3
    when 'M3';      4
    when 'QG BRD';  5
    when 'QG ARD';  6
    when 'M5';      7
    when 'M5/M7';   8
    when 'M7';      9
    when 'M9';      10
    when 'M9/M10';  11
    when 'M10';     12
    when 'CCB';     12
    when 'QG TD';   13
    when 'QG TD M';   13
    when 'MIPM';    14
    when 'M10a';    14
    when 'QG MIP';  15
    when 'M11';     16
    when 'M12';     17
    when 'M12/M13'; 18
    when 'M13';     19
    when 'M14';     20
    when 'G0';  1
    when 'G2';  2
    when 'G3';  3
    when 'G4';  4
    when 'G5';  6
    when 'G6';  7
    when 'G7';  8
    when 'G8';  9
    when 'G9';  10
    when 'g0';  1
    when 'g2';  2
    when 'g3';  3
    when 'g4';  4
    when 'g5';  6
    when 'g6';  7
    when 'g7';  8
    when 'g8';  9
    when 'g9';  10
    when 'pg0';  1
    when 'pg2';  2
    when 'pg3';  3
    when 'pg4';  4
    when 'pg5';  6
    when 'pg6';  7
    when 'pg7';  8
    when 'pg8';  9
    when 'pg9';  10
    when 'sM1';  3
    when 'sM3';  4
    when 'sM5';  7
    when 'sM13'; 19
    when 'sM14'; 20
    else;        0
    end
  end

end
