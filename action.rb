require_relative "lib/git_hub"

GITHUB_REPOSITORY = ENV.fetch("GITHUB_REPOSITORY")
GITHUB_MILESTONE = ENV.fetch("GITHUB_MILESTONE")


github = GitHub.new(repo: GITHUB_REPOSITORY, milestone: GITHUB_MILESTONE)

begin
  feedback = catch(:feedback) do
   # unless github.exist_repo?
   #   throw :feedback, "I'm sorry, but the repo #{GITHUB_REPOSITORY} does not exist."
   # end

    unless github.exist_milestone?
      throw :feedback, "The milestone #{GITHUB_MILESTONE} does not exist."
    end

    unless github.all_issues_closed?
      throw :feedback, "The milestone #{GITHUB_MILESTONE} can't be released since it has at least an open issue."
    end

    # unless github.all_issues_labeled?
    #   throw :feedback, "The milestone #{GITHUB_MILESTONE} can't be released since it has at least an issue doesn't have the expected labels."
    # end

    unless github.missing_tag?
      throw :feedback, "The tag #{GITHUB_MILESTONE} already exists."
    end

    unless github.required_checks_pass?
      throw :feedback, "At least a required check didn't pass during the last run on the default branch."
    end

    if github.release_milestone
      throw :feedback, "The release `#{GITHUB_REPOSITORY}:#{GITHUB_MILESTONE}` has been drafted at https://github.com/#{GITHUB_REPOSITORY}/releases/tag/#{GITHUB_MILESTONE}."
    end
  end

  puts feedback

rescue StandardError => error
  puts "I'm sorry, but #{error.message}."
end
