# frozen_string_literal: true

require 'octokit'

class GitHub
  def initialize(repo:, milestone:)
    @github_repository = repo
    @milestone = milestone
    #@version = milestone # !!!!
    @client ||= Octokit::Client.new(access_token: ENV.fetch("GITHUB_ACCESS_TOKEN"))
  end

  #def exist_repo?
  #  @client.repository?(@github_repository)
  #end

  def exist_milestone?
    gh_milestone != nil
  end

  def all_issues_closed?
    gh_milestone[:open_issues] == 0
  end

  def missing_tag?
    @client.tags(@github_repository).none? { |repo_tag| repo_tag[:name] == @milestone }
  end

  def required_checks_pass?
    return true
    @client.check_runs_for_ref(@github_repository, dafault_branch)
           .check_runs.select { |check| required_status_checks.include?(check[:name]) }
           .all? { |check| check[:status] == "completed" && check[:conclusion] == "success" }
  end

  def release_milestone
     create_release
     close_milestone
   # Documentation.new(@github_repository).publish
    true
  end

  private

  def gh_milestone
    @gh_milestone ||= @client.milestones(@github_repository, state: "all")
                             .detect { |repo_milestone| repo_milestone[:title] == @milestone }
  end

  def required_status_checks
    @client.branch_protection(@github_repository, dafault_branch)[:required_status_checks][:contexts]
  end

  def dafault_branch
    @client.repository(@github_repository)[:default_branch]
  end

  def close_milestone
    @client.update_milestone(@github_repository, gh_milestone[:number], { state: 'closed' })
  end

  def gh_milestone
    @gh_milestone ||= @client.milestones(@github_repository, state: 'all').detect { |repo_milestone| repo_milestone[:title] == @milestone }
  end

  def milestone_issues
      @client.issues(@github_repository, milestone: gh_milestone[:number], state: 'all')
  end
  
  def changelog_issues
    milestone_issues.reject { |issue| !(issue[:labels].map(&:name) & ENV['GITHUB_LABELS_TO_IGNORE'].split('#')).empty? }
  end

  def create_release
      body = "This release comes with the following changes:\n"
      changelog_issues.each do |issue|
        body << "[#{issue[:number]}](#{issue[:html_url]}) - #{issue[:title]}\n"
      end
      body << "\n\nRefer to [the milestone page](#{gh_milestone[:html_url]}?closed=1) for more details."

      @client.create_release(@github_repository, @version, { target_commitish: dafault_branch, name: @milestone, body: body })
    end
end
