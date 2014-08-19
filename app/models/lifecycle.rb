class Lifecycle < ActiveRecord::Base
  has_many :projects, :dependent=>:nullify
  has_many :lifecycle_questions, :dependent=>:nullify
  has_many :lifecycle_milestones, :dependent=>:nullify, :order => "index_order"
  has_many :pm_type_axe, :through => :lifecycle_questions


  def self.get_default
    lifecycle_name = APP_CONFIG['report_project_creation_lifecycle']
    if lifecycle_name
      return Lifecycle.get_with_name(lifecycle_name)
    end
    return nil
  end
  
  # For project creation from stream
  def self.get_case_one
  	lifecycle_name = APP_CONFIG['stream_project_creation_lifecycle_1']
  	if lifecycle_name
  		return Lifecycle.get_with_name(lifecycle_name)
  	end
  	return nil
  end
  
  def self.get_case_two
  	lifecycle_name = APP_CONFIG['stream_project_creation_lifecycle_2']
  	if lifecycle_name
  		return Lifecycle.get_with_name(lifecycle_name)
  	end
  	return nil
  end

  def self.get_with_name(lifecycle_name)
  	Lifecycle.find(:first,:conditions => ["name LIKE ?", "%#{lifecycle_name}%"])
  end

end
