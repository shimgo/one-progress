require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'POST create' do
    context 'リクエストヘッダ\'omniauth.auth\'がセットされている場合' do
      let(:omniauth_env) do
        {uid: 'sample'}
      end

      before do
        request.env['omniauth.auth'] = omniauth_env
      end

      it 'リクエストヘッダ\'omniauth.auth\'を引数にしてUserモデルのfind_or_create_from_auth_hashメソッドを呼び出すこと' do
        user = FactoryGirl.build(:user)
        allow(User).to receive(:find_or_create_from_auth_hash).and_return(user)
        post :create, user: user.attributes
        expect(User).to have_received(:find_or_create_from_auth_hash).with(omniauth_env)
      end

      it 'log_inメソッドを呼び出すこと' do
        allow(controller).to receive(:log_in)
        user = FactoryGirl.build(:user)
        allow(User).to receive(:find_or_create_from_auth_hash).and_return(user)
        post :create, user: user.attributes
        expect(controller).to have_received(:log_in)
      end

      it 'root_pathにリダイレクトすること' do
        user = FactoryGirl.build(:user)
        allow(User).to receive(:find_or_create_from_auth_hash).and_return(user)
        post :create, user: user.attributes
        expect(response).to redirect_to root_path
      end
    end

    context 'リクエストヘッダ\'omniauth.auth\'がセットされていない場合' do
      context 'リクエストパラメータ[:user][:username]がセットされている場合' do
        it 'log_inメソッドを呼び出すこと' do
          allow(controller).to receive(:log_in)
          post :create, user: FactoryGirl.attributes_for(:user)
          expect(controller).to have_received(:log_in)
        end

        it 'root_pathにリダイレクトすること' do
          allow(controller).to receive(:log_in)
          post :create, user: FactoryGirl.attributes_for(:user)
          expect(response).to redirect_to root_path
        end

        context '入力が有効の場合' do
          it 'usersテーブルにレコードを1件追加すること' do
            expect{post :create, user: FactoryGirl.attributes_for(:user)}.to change(User, :count).by(1)
          end
        end

        context '入力が無効の場合' do
          it 'usersテーブルにレコード追加されないこと' do 
            expect{ post :create, user: FactoryGirl.attributes_for(:user, :invalid_user) }
              .not_to change(User, :count)
          end

          it 'root_pathにリダイレクトすること' do
            post :create, user: FactoryGirl.attributes_for(:user, :invalid_user)
            expect(response).to redirect_to root_path
          end

          it 'flash[:alert]にUserモデルのエラーメッセージをセットすること' do
            user = FactoryGirl.build(:user, :invalid_user)
            
            post :create, user: user.attributes
            user.invalid?
            expect(flash[:alert]).to eq user.errors.full_messages
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'log_outメソッドを呼び出すこと' do
      allow(controller).to receive(:log_out)
      delete :destroy
      expect(controller).to have_received(:log_out)
    end

    it 'root_pathにリダイレクトすること' do
      allow(controller).to receive(:log_out)
      delete :destroy
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET #failure' do
    it '\'認証に失敗しました\'メッセージを含む配列をflash[:alert]にセットすること' do
      get :failure
      expect(flash[:alert]).to eq ['認証に失敗しました']
    end

    it 'root_pathにリダイレクトすること' do
      get :failure
      expect(response).to redirect_to root_path
    end
  end
end
