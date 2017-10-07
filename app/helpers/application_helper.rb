module ApplicationHelper
  def url_for_twitter(twitter_user)
    "https://twitter.com/#{twitter_user.nickname}"
  end

  def link_twitter_user_name(twitter_user)
    link_to(url_for_twitter(twitter_user), class: 'h5') do
      concat content_tag(:span, twitter_user.user.username, class: 'bold')
      concat content_tag(:span, " @#{twitter_user.nickname}",
                         class: 'h6 text-muted')
    end
  end
end
