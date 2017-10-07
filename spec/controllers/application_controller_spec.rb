require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#authenticate' do
    controller do
      before_action :authenticate
      def index
        render text: 'dummy'
      end
    end

    context 'ログインしている場合' do
      it 'root_pathにリダイレクトしないこと' do
        allow(controller).to receive(:logged_in?).and_return(true)
        get :index
        expect(response).not_to redirect_to root_path
      end
    end

    context 'ログインしていない場合' do
      it 'root_pathにリダイレクトすること' do
        get :index
        expect(response).to redirect_to root_path
      end

      it 'flash[:alert]に\'ログインしてください\'を含む配列をセットすること' do
        get :index
        expect(flash[:alert]).to eq ['ログインしてください']
      end
    end
  end

  describe '#before_action, #after_action' do
    controller do
      def index
        render text: 'dummy'
      end
    end

    it 'write_started_log、write_started_logの順番で呼び出されること' do
      allow(controller).to receive(:write_started_log)
      allow(controller).to receive(:write_finished_log)

      get :index
      expect(controller).to have_received(:write_started_log).ordered
      expect(controller).to have_received(:write_finished_log).ordered
    end
  end
end
