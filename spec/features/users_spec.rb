require 'rails_helper'

feature 'ユーザ関連の操作' do
  scenario 'ゲストユーザでログインしてからログアウト', js: true do
    user = FactoryGirl.build(:user, username: 'feature_test')
    visit root_path

    expect(page).not_to have_content user.username
    expect(page).not_to have_link 'ログアウト'
    expect(page).to have_link 'ログイン'

    expect {
      login_as_guest_user(user.username)
    }.to change{[User.count, GuestUser.count]}.by([1, 1])
    expect(page).to have_content user.username
    expect(page).not_to have_link 'ログイン'

    find_link('ログアウト').click
    expect(page).not_to have_content user.username
    expect(page).to have_link 'ログイン'
    expect(page).not_to have_link 'ログアウト'
  end

  scenario 'ゲストユーザには退会が存在しない', js: true do
    visit root_path

    login_as_guest_user('feature_test')
    expect(page).not_to have_content '退会'
  end

  scenario 'Twitterユーザで初めてログインしてからログアウト後、再びログイン', js: true do
    user = FactoryGirl.build(:user)
    twitter_user = FactoryGirl.build(:twitter_user, user: user)
    visit root_path

    expect(page).not_to have_content('ログアウト')
    expect(page).to have_link('Twitterでログイン')

    expect {
      login_as_twitter_user(twitter_user)
    }.to change(User, :count).by(1)
      .and change(TwitterUser, :count).by(1)
    expect(page).to have_content('ログアウト')
    expect(page).not_to have_link('Twitterでログイン')
    expect(page).to have_link(twitter_user.user.username)
    expect(page).to have_link(twitter_user.nickname)

    find_link('ログアウト').click
    expect(page).not_to have_content('ログアウト')
    expect(page).to have_link('Twitterでログイン')
    expect(page).not_to have_link(twitter_user.user.username)
    expect(page).not_to have_link(twitter_user.nickname)

    expect {
      login_as_twitter_user(twitter_user)
    }.to change(User, :count).by(0)
      .and change(TwitterUser, :count).by(0)
    expect(page).to have_content('ログアウト')
    expect(page).not_to have_link('Twitterでログイン')
    expect(page).to have_link(twitter_user.user.username)
    expect(page).to have_link(twitter_user.nickname)
  end

  scenario 'Twitterアカウントでの認証に失敗', js: true do
    OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
    visit root_path
    expect(page).not_to have_content('認証に失敗しました')

    find_link('Twitterでログイン').click
    expect(page).to have_content('認証に失敗しました')
  end

  scenario 'Twitterユーザで退会', js: true do
    visit root_path
    login_as_twitter_user

    expect(page).to have_content('ログアウト')
    expect(page).not_to have_link('Twitterでログイン')

    expect {
      find_link('退会').click
      find_button('退会する').click
      find('.modal-header', text: '退会しますか？')
      find_link('退会', {class: 'btn-danger'}).click
      expect(page).to have_content('退会完了しました')
    }.to change(User, :count).by(-1)
      .and change(TwitterUser, :count).by(-1)
    expect(page).not_to have_content('ログアウト')
    expect(page).to have_link('Twitterでログイン')
  end
end
