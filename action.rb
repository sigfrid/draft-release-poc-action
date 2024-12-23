require_relative "lib/git_hub"

GITHUB_REPOSITORY = ENV.fetch("GITHUB_REPOSITORY")
GITHUB_MILESTONE = ENV.fetch("GITHUB_MILESTONE")


github = GitHub.new(repo: GITHUB_REPOSITORY, milestone: GITHUB_MILESTONE)

begin
  feedback = catch(:feedback) do
    unless github.exist_repo?
      throw :feedback, "I'm sorry, but the repo #{GITHUB_REPOSITORY} does not exist."
    end

    if true
      throw :feedback, "The release `#{GITHUB_REPOSITORY}:#{GITHUB_MILESTONE}` has been drafted at https://github.com/#{GITHUB_REPOSITORY}/releases/tag/#{GITHUB_MILESTONE}."
    end
  end

  puts feedback

rescue StandardError => error
  puts "I'm sorry, but #{error.message}."
end
