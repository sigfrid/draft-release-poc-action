# frozen_string_literal: true

require "octokit"

class GitHub
  REQUIRED_LABELS = %w[accepted approved confirmed].freeze

  def initialize(repo:, milestone:)
    @repository = repo
    @milestone_title = milestone
    @client ||= Octokit::Client.new(access_token: ENV.fetch("GITHUB_ACCESS_TOKEN"))
  end

  def exist_milestone?
    milestone != nil
  end

  def all_issues_closed?
    milestone[:open_issues] == 0
  end

  def all_issues_labeled?
      milestone_issues.map { |issue| issue[:labels].map { |label| label[:name] } }
                      .all? { |label_list| (REQUIRED_LABELS & label_list) == REQUIRED_LABELS }
  end

  def missing_tag?
    @client.tags(@repository).none? { |tag| tag[:name] == @milestone_title }
  end

  def required_checks_pass?
    @client.check_runs_for_ref(@repository, dafault_branch)
           .check_runs.select { |check| required_status_checks.include?(check[:name]) }
           .all? { |check| check[:status] == "completed" && check[:conclusion] == "success" }
  end

  private

  def milestone
    @milestone ||= @client.milestones(@repository, state: "all")
                             .detect { |milestone| milestone[:title] == @milestone_title }
  end

  def milestone_issues
    @client.issues(@repository, milestone: milestone[:number], state: "all")
  end

  def required_status_checks
    @client.branch_protection(@repository, dafault_branch)[:required_status_checks][:contexts]
  end

  def dafault_branch
    @dafault_branch ||= @client.repository(@repository)[:default_branch]
  end
end
