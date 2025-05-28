require_relative "lib/git_hub"

GITHUB_REPOSITORY = ENV.fetch("GITHUB_REPOSITORY")
GITHUB_MILESTONE = ENV.fetch("GITHUB_MILESTONE")

github = GitHub.new(repo: GITHUB_REPOSITORY, milestone: GITHUB_MILESTONE)

begin
  feedback = catch(:feedback) do
    unless github.exist_milestone?
      throw :feedback, "Milestone #{GITHUB_MILESTONE} does not exist."
    end

    unless github.all_issues_closed?
      throw :feedback, "At least an issue is still open."
    end

    unless github.all_issues_labeled?
      throw :feedback, "At least an issue doesn't have the required labels."
    end

    unless github.missing_tag?
      throw :feedback, "Tag #{GITHUB_MILESTONE} already exists."
    end

    unless github.required_checks_pass?
      throw :feedback, "At least a required check didn't pass during the last run on the default branch."
    end
  end

  unless feedback.nil?
    puts feedback
    exit 1
  else
    puts "All checks passed. #{GITHUB_MILESTONE} can be released."
    exit 0
  end

rescue StandardError => error
  puts "I'm sorry, but #{error.message}."
end
