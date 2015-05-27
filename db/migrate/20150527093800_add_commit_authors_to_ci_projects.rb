class AddCommitAuthorsToCiProjects < ActiveRecord::Migration

	def self.up
		add_column :ci_projects, :airbus_commit_author, :text
		add_column :ci_projects, :sqli_commit_author, :text
		add_column :ci_projects, :deployment_commit_author, :text
	end

	def self.down
		remove_column :ci_projects, :commit_author
		remove_column :ci_projects, :sqli_commit_author
		remove_column :ci_projects, :deployment_commit_author
	end
end