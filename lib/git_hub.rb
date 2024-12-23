# frozen_string_literal: true

require 'octokit'

class GitHub
  def initialize(repo:, milestone:)
    @github_repository = repo
    @milestone = milestone
    @version = milestone # !!!!
    @client ||=  Octokit::Client.new(access_token: ENV.fetch("GITHUB_ACCESS_TOKEN"))
  end

  def exist_repo?
    @client.repository?(@github_repository)
  end
end
