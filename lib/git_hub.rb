# frozen_string_literal: true

require 'octokit'

class GitHub
  def initialize(repo:, milestone:)
    @github_repository = repo
    @milestone = milestone
    @version = milestone # !!!!
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
    @client.check_runs_for_ref(@github_repository, dafault_branch)
           .check_runs.select { |check| required_status_checks.include?(check[:name]) }
           .all? { |check| check[:status] == "completed" && check[:conclusion] == "success" }
  end

  def release_milestone
   # create_release
   # close_milestone
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
    #"main"
    @client.repository(@github_repository)[:default_branch]
  end
end
