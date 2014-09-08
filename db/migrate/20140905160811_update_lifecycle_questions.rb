class UpdateLifecycleQuestions < ActiveRecord::Migration

	# TODO : Create all questions references at the lifecyclequestions creation, and only update the question references after that
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
				new_lifecycle_question = q.clone
			 	new_lifecycle_question.lifecycle_id = waterfall_lifecycle.id
			 	new_lifecycle_question.created_at = Time.zone.now
			 	new_lifecycle_question.save

			 	qrs = QuestionReference.find(:all, :conditions => ["question_id = ?", q.id.to_s])
			 	qrs.each do |qr|
			 		if waterfall_milestones_id.include?(qr.milestone_name.id)
				 		new_qr = qr.clone
				 		new_qr.question_id = new_lifecycle_question.id
			 			new_qr.created_at = Time.zone.now
				 		new_qr.save
				 	end
			 	end
			end

			light_gpp_questions.each do |l|
				new_lifecycle_question = l.clone
				new_lifecycle_question.lifecycle_id = waterfall_lifecycle.id
			 	new_lifecycle_question.created_at = Time.zone.now
				new_lifecycle_question.save

				qrs = QuestionReference.find(:all, :conditions => ["question_id = ?", l.id.to_s])
			 	qrs.each do |qr|
			 		if qr.milestone_name.title == 'M5/M7' or qr.milestone_name.title == 'M9/M10' or qr.milestone_name.title == 'M12/M13'
				 		new_qr = qr.clone
				 		new_qr.question_id = new_lifecycle_question.id
			 			new_qr.created_at = Time.zone.now
				 		new_qr.save
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

			 	qrs = QuestionReference.find(:all, :conditions => ["question_id = ?", q.id.to_s])
			 	qrs.each do |qr|
			 		if lbip_plus_milestones_id.include?(qr.milestone_name.id)
				 		new_qr = qr.clone
				 		new_qr.question_id = new_lifecycle_question.id
			 			new_qr.created_at = Time.zone.now
				 		new_qr.save
				 	end
			 	end
			end
		end

	end

	def self.down
	end
end

