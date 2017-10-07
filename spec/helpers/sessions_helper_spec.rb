require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SessionsHelper, type: :helper do
  let(:user_mock) do
    user_mock = double('User user')
    allow(user_mock).to receive(:id).and_return(1)
    allow(user_mock).to receive(:remember_token).and_return('foo')
    allow(user_mock).to receive(:remember)
    allow(user_mock).to receive(:forget)
    allow(user_mock).to receive(:authenticated?)
    user_mock
  end

  describe '#log_in' do
    context 'ログインしている場合' do
      before do
        session[:user_id] = 1
        cookies.signed[:user_id] = 1
        cookies[:remember_token] = 'foo'
      end

      it 'エラーなく終了すること' do
        expect { helper.log_in(user_mock) }.not_to raise_error
      end

      it 'セッションにユーザIDが保存されたままであること' do
        helper.log_in(user_mock)
        expect(session[:user_id]).to eq 1
      end

      it 'cookieにユーザIDが保存されたままであること' do
        helper.log_in(user_mock)
        expect(cookies.signed[:user_id]).to eq 1
      end

      it 'cookieに記憶トークンが保存されたままであること' do
        helper.log_in(user_mock)
        expect(cookies[:remember_token]).to eq 'foo'
      end
    end

    context 'ログインしていない場合' do
      it 'セッションにユーザIDが保存されること' do
        helper.log_in(user_mock)
        expect(session[:user_id]).to eq 1
      end

      it 'ユーザのrememberメソッドが呼び出されること' do
        helper.log_in(user_mock)
        expect(user_mock).to have_received(:remember)
      end

      it 'cookieに暗号化されたユーザIDが保存されること' do
        helper.log_in(user_mock)
        expect(cookies.signed[:user_id]).to eq 1
      end

      it 'cookieに記憶トークンが保存されること' do
        helper.log_in(user_mock)
        expect(cookies[:remember_token]).to eq 'foo'
      end
    end
  end

  describe '#log_out' do
    context 'ログインしている場合' do
      before do
        session[:user_id] = 1
        cookies.signed[:user_id] = 1
        cookies[:remember_token] = 'foo'
      end

      it 'ユーザのforgetメソッドが呼び出されること' do
        allow(helper).to receive(:current_user).and_return(user_mock)
        helper.log_out
        expect(user_mock).to have_received(:forget)
      end

      it 'cookieに保存されていたユーザIDがクリアされること' do
        allow(helper).to receive(:current_user).and_return(user_mock)
        helper.log_out
        expect(cookies[:user_id]).to be_nil
      end

      it 'cookieに保存されていた記憶トークンがクリアされること' do
        allow(helper).to receive(:current_user).and_return(user_mock)
        helper.log_out
        expect(cookies[:remember_token]).to be_nil
      end
    end

    context 'ログインしていない場合' do
      it 'forgetメソッドが呼び出されないこと' do
        allow(helper).to receive(:forget)
        helper.log_out
        expect(helper).not_to have_received(:forget)
      end

      it 'エラーなく終了すること' do
        expect { helper.log_out }.not_to raise_error
      end
    end
  end

  describe '#current_user' do
    context 'cookieが残っている場合' do
      before do
        cookies.signed[:user_id] = 1
        cookies[:remember_token] = 'foo'
      end

      context 'セッションが残っている場合' do
        before { session[:user_id] = 1 }

        it 'User::find_byメソッドで見つかったユーザを返すこと' do
          allow(User).to receive(:find_by).and_return(user_mock)
          expect(helper.current_user).to eq user_mock
        end

        context '２回目以降に実行する場合' do
          it 'User::find_byメソッドが1度だけ呼ばれること' do
            allow(User).to receive(:find_by).and_return(true)
            helper.current_user
            helper.current_user
            expect(User).to have_received(:find_by).once
          end
        end
      end

      context 'セッションが残っていない場合' do
        context 'cookieのユーザIDに一致するユーザが見つからなかった場合' do
          it 'nilを返すこと' do
            allow(User).to receive(:find_by).and_return(nil)
            expect(helper.current_user).to be_nil
          end
        end

        context 'cookieのユーザIDに一致するユーザが見つかった場合' do
          it 'User#authenticated?の引数にcookieに保存されている記憶トークンが渡されること' do
            allow(User).to receive(:find_by).and_return(user_mock)
            helper.current_user
            expect(user_mock).to have_received(:authenticated?).with(cookies[:remember_token])
          end

          context 'User#authenticated?の認証に成功した場合' do
            before do
              allow(user_mock).to receive(:authenticated?).and_return(true)
              allow(User).to receive(:find_by).and_return(user_mock)
            end

            it 'セッションにユーザIDが保存されること' do
              helper.current_user
              expect(session[:user_id]).to eq 1
            end

            it 'cookieに暗号化されたユーザIDが保存されること' do
              helper.current_user
              expect(cookies.signed[:user_id]).to eq 1
            end

            it 'cookieに記憶トークンが保存されること' do
              helper.current_user
              expect(cookies[:remember_token]).to eq 'foo'
            end

            it 'User::find_byメソッドで見つかったユーザを返すこと' do
              expect(helper.current_user).to eq user_mock
            end
          end

          context 'User#authenticated?の認証に失敗した場合' do
            before do
              allow(user_mock).to receive(:authenticated?).and_return(false)
              allow(User).to receive(:find_by).and_return(user_mock)
            end

            it 'セッションにユーザIDが保存されないこと' do
              helper.current_user
              expect(session[:user_id]).to be_nil
            end

            it 'nilを返すこと' do
              expect(helper.current_user).to be_nil
            end
          end
        end
      end
    end

    context 'cookieが残っていない場合' do
      context 'セッションが残っている場合' do
        before { session[:user_id] = 1 }

        it '例外が発生すること' do
          expect { helper.current_user }.to raise_error(
            /cookieのユーザIDがnilの場合はセッションのユーザIDもnilである必要があります。/
          )
        end
      end

      context 'セッションが残っていない場合' do
        it 'nilを返すこと' do
          allow(User).to receive(:find_by).and_return(nil)
          expect(helper.current_user).to be_nil
        end
      end
    end
  end

  describe '#logged_in?' do
    context 'current_userがnilの場合' do
      before { allow(helper).to receive(:current_user).and_return(nil) }

      it 'falseを返すこと' do
        expect(helper.logged_in?).to eq false
      end
    end

    context 'current_userがnil以外の場合' do
      before { allow(helper).to receive(:current_user).and_return('foo') }

      it 'trueを返すこと' do
        expect(helper.logged_in?).to eq true
      end
    end
  end
end
