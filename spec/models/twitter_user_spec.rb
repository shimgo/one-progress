require 'rails_helper'

RSpec.describe TwitterUser, type: :model do
  describe 'validation' do
    it 'uidがnilの場合無効であること' do
      twitter_user = TwitterUser.new(uid: nil)
      twitter_user.valid?
      expect(twitter_user.errors[:uid]).to be_present
    end

    it 'uidがnil以外の場合有効であること' do
      twitter_user = TwitterUser.new(uid: 'test')
      expect(twitter_user).to be_valid
    end
  end

  describe '::find_or_create_from_auth_hash' do
    let(:auth_hash) do
      {
        uid: 'test', 
        info: {nickname: 'testuser', image: 'http://test'}
      }
    end

    context '新規ユーザの場合' do
      it '保存したTwitterUserのインスタンスを返すこと' do
        expect(TwitterUser.find_or_create_from_auth_hash(auth_hash)
              ).to eq TwitterUser.find_by(uid: auth_hash[:uid])
      end

      it 'TwitterUser.uidに引数のキー[:uid]の値をセットして保存すること' do
        TwitterUser.find_or_create_from_auth_hash(auth_hash)
        twitter_user = TwitterUser.find_by(uid: auth_hash[:uid])
        expect(twitter_user.uid).to eq auth_hash[:uid]
      end

      it 'User#usernameに引数のキー[:info][:nickname]の値をセットして保存すること' do
        twitter_user = TwitterUser.find_or_create_from_auth_hash(auth_hash)
        user = User.find(twitter_user.user_id)
        expect(user.username).to eq auth_hash[:info][:nickname]
      end

      it 'User#image_urlに引数のキー[:info][:image]の値をセットして保存すること' do
        twitter_user = TwitterUser.find_or_create_from_auth_hash(auth_hash)
        user = User.find(twitter_user.user_id)
        expect(user.image_url).to eq auth_hash[:info][:image]
      end
    end

    context '既存ユーザの場合' do
      it '引数のキー[:uid]の値と一致するuidを持つTwitterUserのインスタンスを返すこと' do
        twitter_user = TwitterUser.new(uid: auth_hash[:uid])
        twitter_user.user = User.new(username: auth_hash[:info][:nickname],
                                     image_url: auth_hash[:info][:image])
        twitter_user.save!
        expect(TwitterUser.find_or_create_from_auth_hash(auth_hash)
              ).to eq twitter_user
      end
    end
  end
end
