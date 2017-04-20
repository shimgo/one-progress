module LoginMacro
  def login_as_guest_user(username)
    find_field('ユーザー名').set username
    find_button('ログイン').click
    find_link('ログアウト')
  end

  def login_as_twitter_user(twitter_user = nil)
    twitter_user = FactoryGirl.build(:twitter_user, :with_user) unless twitter_user
    OmniAuth.config.mock_auth[:twitter] =
      OmniAuth::AuthHash.new(
        provider: 'twitter',
        uid: twitter_user.uid,
        info: {
          nickname: twitter_user.nickname,
          name: twitter_user.user.username,
          image: twitter_user.user.image_url
        }
      ) unless OmniAuth.config.mock_auth[:twitter]
    find_link('Twitterでログイン').click
    find_link('ログアウト')
  end
end
