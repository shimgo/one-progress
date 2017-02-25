require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'DELETE #destroy' do
    let(:user) do 
      FactoryGirl.build(:user)
    end

    context '認証に成功した場合' do
      before do
        allow(user).to receive(:authenticated?).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'reset_sessionメソッドを呼び出すこと' do
        allow(controller).to receive(:reset_session)
        delete :destroy
        expect(controller).to have_received(:reset_session)
      end

      it 'current_userを引数にしてforgetメソッドを呼び出すこと' do
        allow(controller).to receive(:forget)
        delete :destroy
        expect(controller).to have_received(:forget).with(user)
      end

      it 'root_pathにリダイレクトすること' do
        delete :destroy
        expect(response).to redirect_to root_path
     end

      it 'flash[:notice]に\'退会完了しました\'メッセージがセットされること' do
        delete :destroy
        expect(flash[:notice]).to eq '退会完了しました'
      end
    end

    context '認証に失敗した場合' do
      before do
        allow(user).to receive(:authenticated?).and_return(false)
        allow(controller).to receive(:current_user).and_return(user)
      end
      
      it '\'authentication failed. [クラス名] id:[ユーザID]\'メッセージを引数にしてwrite_failure_logメソッドを呼び出していること' do
        allow(controller).to receive(:write_failure_log)
        delete :destroy
        expect(controller).to have_received(:write_failure_log)
          .with("authentication failed. #{user.class} id:#{user.id}")
      end

      it '400エラーページに遷移すること' do
        delete :destroy
        expect(response).to render_template({file: "#{Rails.root}/public/400.html"})
      end

      it 'httpステータスコード:unauthorized(401)を返すこと' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
