module GitHelper
  def get_git_client
    if has_git_access_token?
      Octokit::Client.new(access_token: current_user.git_access_token)
    end
  end

  def has_git_access_token?
    current_user.git_access_token?
  end
end
