require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validation' do
    describe 'username' do
      it '空であれば無効であること' do
        user = User.new(username: nil)
        user.valid?
        expect(user.errors[:username]).to be_present
      end

      it '入力文字数が20文字以内であれば有効であること' do
        user = User.new(username: 'あ' * 20)
        expect(user).to be_valid
      end

      it '入力文字数が20文字超であれば無効であること' do
        user = User.new(username: 'あ' * 21)
        user.valid?
        expect(user.errors[:username]).to be_present
      end
    end
  end

  describe '::find_or_create_from_auth_hash' do
    context '引数のキー:providerが"twitter"の場合' do
      let(:auth_hash) do
        {
          uid: '1',
          provider: 'twitter',
          info: {name: 'ユーザ1', nickname: 'testuser'}
        }
      end

      let(:twitter_user_mock) do
        mock = double('Twitter twitter_user')
        allow(mock).to receive(:user).and_return(User.new(username: 'mockuser'))
        mock
      end

      it 'TwitterUser::find_or_create_from_auth_hashに引数が渡されること' do
        allow(TwitterUser).to receive(:find_or_create_from_auth_hash)
          .and_return(twitter_user_mock)

        User.find_or_create_from_auth_hash(auth_hash)
        expect(TwitterUser).to have_received(:find_or_create_from_auth_hash)
          .with(auth_hash)
      end

      it 'TwitterUser#userの結果を返すこと' do
        allow(TwitterUser).to receive(:find_or_create_from_auth_hash)
          .and_return(twitter_user_mock)

        expect(User.find_or_create_from_auth_hash(auth_hash))
          .to eq twitter_user_mock.user
      end

      context '引数のユーザ名が登録済みのユーザ名と異なっていたとき'do
        it 'ユーザ名を引数のユーザ名で更新すること' do
          origin_user = TwitterUser.new(uid: auth_hash[:uid])
          origin_user.user = User.new(username: '変更前ユーザ')
          origin_user.save!
          allow(TwitterUser).to receive(:find_or_create_from_auth_hash)
            .and_return(origin_user)

          User.find_or_create_from_auth_hash(auth_hash)
          user = User.find(origin_user.user.id)
          expect(user.username).to eq auth_hash[:info][:name]
        end
      end
    end

    context '引数のキー:providerが"twitter"以外の場合' do
      let(:auth_hash){ {provider: 'other'} }

      it 'nilを返すこと' do
        expect(User.find_or_create_from_auth_hash(auth_hash)).to be_nil
      end
    end
  end

  describe '::digest' do
    it '暗号化された長さ60の文字列を返すこと' do
      expect(User.digest('test').length).to eq 60
    end
  end

  describe '::new_token' do
    it 'SecureRandomによるURL-safe base64文字列を返すこと' do
      allow(SecureRandom).to receive(:urlsafe_base64).and_return('test')
      expect(User.new_token).to eq 'test'
    end
  end

  describe '#remember' do
    it 'remember_digestが暗号化された長さ60字の文字列で更新されること' do
      user = User.create(username: 'user_remember_test')
      user.remember
      updated_user = User.find_by(username: 'user_remember_test')
      expect(updated_user.remember_digest.length).to eq 60
    end

    it '#remember_tokenにUser::new_tokenの値がセットされること' do
      allow(User).to receive(:new_token).and_return('test')
      user = User.create(username: 'user_remember_test')
      user.remember
      expect(user.remember_token).to eq 'test'
    end
  end

  describe '#forget' do
    it 'remember_digestがnilで更新されること' do
      user = User.create(username: 'user_forget_test', remember_digest: 'test')
      user.forget
      updated_user = User.find_by(username: 'user_forget_test')
      expect(updated_user.remember_digest).to be_nil
    end
  end

  describe '#authenticated?' do
    it '引数がnilの場合、falseを返すこと' do
      user = User.new(username: 'test')
      expect(user.authenticated?(nil)).to eq false
    end

    context '引数のトークンが記憶ダイジェストと一致する場合' do
      it 'trueを返すこと' do
        user = User.create(username: 'test')
        token = SecureRandom.urlsafe_base64
        user.remember_token = token
        user.update_attributes(remember_digest: User.digest(user.remember_token))
        expect(user.authenticated?(token)).to eq true
      end
    end

    context '引数のトークンが記憶ダイジェストと一致しなかった場合' do
      it 'falseを返すこと' do
        user = User.create(username: 'test')
        user.remember_token = SecureRandom.urlsafe_base64
        user.update_attributes(remember_digest: User.digest(user.remember_token))
        expect(user.authenticated?('test')).to eq false
      end
    end
  end
end
