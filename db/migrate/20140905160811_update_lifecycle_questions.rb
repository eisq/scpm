class UpdateLifecycleQuestions < ActiveRecord::Migration

	def self.up
		full_gpp_lifecycle 	= Lifecycle.find(:first, :conditions => ["name = 'Full GPP'"])
		waterfall_lifecycle = Lifecycle.find(:first, :conditions => ["name = 'Waterfall'"])
		lbip_Gx_lifecycle 	= Lifecycle.find(:first, :conditions => ["name = 'LBIP Gx'"])
		lbip_plus_lifecycle = Lifecycle.find(:first, :conditions => ["name = 'LBIP+'"])
		light_gpp_lifecycle = Lifecycle.find(:first, :conditions => ["name = 'Light GPP'"])

		waterfall_milestones_id = waterfall_lifecycle.lifecycle_milestones.map {|lm| lm.milestone_name.id }
		lbip_plus_milestones_id = lbip_plus_lifecycle.lifecycle_milestones.map {|lm| lm.milestone_name.id }

		# FULL GPP / WATERFALL
		full_gpp_questions 		= LifecycleQuestion.find(:all, :conditions => ["lifecycle_id = ?", full_gpp_lifecycle.id.to_s])
		light_gpp_questions 	= LifecycleQuestion.find(:all, :conditions => ["lifecycle_id = ?", light_gpp_lifecycle.id.to_s])
		lbip_Gx_questions 		= LifecycleQuestion.find(:all, :conditions => ["lifecycle_id = ?", lbip_Gx_lifecycle.id.to_s])

		if waterfall_lifecycle
			full_gpp_questions.each do |q|
				# Create lifecycle question
				new_lifecycle_question = q.clone
			 	new_lifecycle_question.lifecycle_id = waterfall_lifecycle.id
			 	new_lifecycle_question.created_at = Time.zone.now
			 	new_lifecycle_question.save

			 	# Create question references
			 	waterfall_milestones_id.each do |q_m|
			 	   	qf_new = QuestionReference.new
			       	qf_new.question_id = new_lifecycle_question.id
			       	qf_new.milestone_id = q_m
			       	qf_new.note = 0
			       	qf_new.save
			 	
			 		# Update question references data
			       	qrs = QuestionReference.find(:first, :conditions => ["question_id = ? and milestone_id = ?", q.id.to_s, q_m.to_s])
			       	if qrs
			    		qf_new.note = qrs.note
			       		qf_new.save
			       	end
			 	end
			end

			light_gpp_questions.each do |l|

				old_lifecycle_question = LifecycleQuestion.find(:first, :conditions => ["text LIKE '?' and lifecycle_id = ?", l.text, waterfall_lifecycle.id.to_s])
				new_lifecycle_question = nil
				if old_lifecycle_question
					new_lifecycle_question = old_lifecycle_question
				else
					new_lifecycle_question = l.clone
					new_lifecycle_question.lifecycle_id = waterfall_lifecycle.id
				 	new_lifecycle_question.created_at = Time.zone.now
					new_lifecycle_question.save
				end

				# Create question references
			 	waterfall_milestones_id.each do |q_m|
			 		qf_new = nil
			 		if old_lifecycle_question == nil
				 	   	qf_new = QuestionReference.new
				       	qf_new.question_id = new_lifecycle_question.id
				       	qf_new.milestone_id = q_m
				       	qf_new.note = 0
				       	qf_new.save
				    else
				    	qf_new = QuestionReference.find(:first, :conditions => ["question_id = ? and milestone_id = ?", new_lifecycle_question.id.to_s, q_m.to_s])
				    end

					# Update question references data
			       	qrs = QuestionReference.find(:first, :conditions => ["question_id = ? and milestone_id = ?", l.id.to_s, q_m.to_s])
			       	if qrs and qf_new and (qrs.milestone_name.title == 'M5/M7' or qrs.milestone_name.title == 'M9/M10' or qrs.milestone_name.title == 'M12/M13')
			    		qf_new.note = qrs.note
			       		qf_new.save
			       	end
			    end
			end
		end

		# lbip Gx / lbip +
		if lbip_plus_lifecycle
			lbip_Gx_questions.each do |q|
				new_lifecycle_question = q.clone
			 	new_lifecycle_question.lifecycle_id = lbip_plus_lifecycle.id
			 	new_lifecycle_question.created_at = Time.zone.now
			 	new_lifecycle_question.save

				# Create question references
				lbip_plus_milestones_id.each do |q_m|
			 	   	qf_new = QuestionReference.new
			       	qf_new.question_id = new_lifecycle_question.id
			       	qf_new.milestone_id = q_m
			       	qf_new.note = 0
			       	qf_new.save

					# Update question references data
			       	qrs = QuestionReference.find(:first, :conditions => ["question_id = ? and milestone_id = ?", q.id.to_s, q_m.to_s])
			       	if qrs
			    		qf_new.note = qrs.note
			       		qf_new.save
			       	end
				end
			end
		end

	end

	def self.down
	end
end

