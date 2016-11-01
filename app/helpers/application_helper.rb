module ApplicationHelper
  def url_for_twitter(user)
    "https://twitter.com/#{user.username}"
  end
end
