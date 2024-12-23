# frozen_string_literal: true

require 'octokit'

class GitHub
  def initialize(repo:, milestone:)
    @github_repository = repo
    @milestone = milestone
    @version = milestone # !!!!
    @client ||=  Octokit::Client.new(access_token: ENV.fetch("GITHUB_ACCESS_TOKEN"))
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

  private

  def gh_milestone
    @gh_milestone ||= @client.milestones(@github_repository, state: "all")
                             .detect { |repo_milestone| repo_milestone[:title] == @milestone }
  end
end
