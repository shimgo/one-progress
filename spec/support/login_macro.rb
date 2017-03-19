module LoginMacro
  def login_as_guest_user(username)
    find_field('ユーザー名').set username
    find_button('ログイン').click
    find_link('ログアウト')
  end

  def login_as_twitter_user(name: 'name', nickname: 'nickname')
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      provider: 'twitter',
      uid: '123545',
      info: {
        nickname: nickname,
        name: name,
        image: '/assets/guest_user.png'
      }
    }) unless OmniAuth.config.mock_auth[:twitter]
    find_link('Twitterでログイン').click
    find_link('ログアウト')
  end
end
