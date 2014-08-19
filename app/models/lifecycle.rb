class Lifecycle < ActiveRecord::Base
  has_many :projects, :dependent=>:nullify
  has_many :lifecycle_questions, :dependent=>:nullify
  has_many :lifecycle_milestones, :dependent=>:nullify, :order => "index_order"
  has_many :pm_type_axe, :through => :lifecycle_questions
end
