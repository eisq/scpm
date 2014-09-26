class MilestoneName < ActiveRecord::Base
  has_many    :checklist_item_template_milestone_name, :dependent=>:destroy
  has_many    :checklist_item_templates, :through => :checklist_item_template_milestone_name
  has_many    :question_references
  has_many    :deviation_question_milestone_names


def self.get_active_sorted
	milestone_names_base = MilestoneName.find(:all, :conditions=>["is_active = 1"], :order=>"title desc")
	sorted_milestone_names_array = Array.new
	temp_milestone_names_hash  = Hash.new
		
	# hash[milestone_name_without_number] = list of milestone names
	milestone_names_base.each do |mn|
		mn_without_number = mn.title.gsub(/[^a-zA-Z ]/,'')
		if temp_milestone_names_hash[mn_without_number] == nil
			temp_milestone_names_hash[mn_without_number] = Array.new
		end
		temp_milestone_names_hash[mn_without_number] << mn
	end

	# Order each list of milestone names in the hash
	temp_milestone_names_hash.each do |hash_mn_key, hash_mn_value|
		# If milestone_names with number
		if hash_mn_value.size > 1
			temp_milestone_names_hash[hash_mn_key] = hash_mn_value.sort { |a,b| a.title.scan(/\d+/).first.to_i <=> b.title.scan(/\d+/).first.to_i }				
		end
	end

	# Order keys of hash
	temp_milestone_names_hash.sort_by { |key, value| key.downcase }.each do |hash_mn_key, hash_mn_value|
		hash_mn_value.each do |mn_object|
			sorted_milestone_names_array << mn_object
		end
	end

	return sorted_milestone_names_array
end

end
