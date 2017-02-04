require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  describe 'GET #index' do
    it ':indexテンプレートを表示すること' do
      get :index
      expect(response).to render_template :index
    end

    context 'ログインしている場合' do
      let(:user) do
        FactoryGirl.build(:user)
      end

      before do
        allow_any_instance_of(TasksController).to receive(:current_user).and_return(user)
      end

      it 'ログインユーザの未着手タスクを@untouched_tasksに作成日が新しい順に格納していること' do
        user.created_tasks << FactoryGirl.build_list(:task, 5, status: :untouched)
        allow(user.created_tasks).to receive(:untouched).and_return(user.created_tasks)

        get :index
        expect(assigns(:untouched_tasks)).to match(user.created_tasks.order('created_at DESC').to_a) 
      end

      it 'ログインユーザの保留タスクを@suspended_tasksに作成日が新しい順に格納していること' do
        user.created_tasks << FactoryGirl.build_list(:task, 5, status: :suspended)
        allow(user.created_tasks).to receive(:suspended).and_return(user.created_tasks)

        get :index
        expect(assigns(:suspended_tasks)).to match(user.created_tasks.order('created_at DESC').to_a) 
      end

      it 'ログインユーザの完了タスクを@finished_tasksに作成日が新しい順に格納していること' do
        user.created_tasks << FactoryGirl.build_list(:task, 5, status: :finished)
        allow(user.created_tasks).to receive(:finished).and_return(user.created_tasks)

        get :index
        expect(assigns(:finished_tasks)).to match(user.created_tasks.order('created_at DESC')) 
      end

      it 'ログインユーザの進行中タスクを@user_tasks_in_progressに作成日が新しい順に格納していること' do
        user.created_tasks << FactoryGirl.build_list(:task, 5, status: :started)
        allow(user.created_tasks).to receive(:in_progress).and_return(user.created_tasks)

        get :index
        expect(assigns(:user_tasks_in_progress)).to match(user.created_tasks.order('created_at DESC').to_a) 
      end

      it 'ログインユーザ以外のすべてのユーザのタスクを@all_tasks_in_progresに作成日が新しい順に格納すること' do
        other_users = FactoryGirl.create_list(:user, 5, :with_started_task)
        other_user_tasks_in_progress = Task.where(owner: other_users)
        FactoryGirl.create(:task, status: :started, owner: user)
        all_tasks_including_logged_in_user = Task.where(owner: other_users << user)
        allow(Task).to receive(:in_progress).and_return(all_tasks_including_logged_in_user)

        get :index
        expect(assigns(:all_tasks_in_progress)).to match(other_user_tasks_in_progress.order('created_at DESC').to_a)
      end
    end

    context 'ログインしていない場合' do
      it '@untouched_tasksがnilであること' do
        FactoryGirl.create_list(:task, 21, status: :untouched)
        get :index
        expect(assigns(:@untouched_tasks)).to be_nil
      end

      it '@suspended_tasksがnilであること' do
        FactoryGirl.create_list(:task, 21, status: :suspended)
        get :index
        expect(assigns(:@suspended_tasks)).to be_nil
      end

      it '@finished_tasksがnilであること' do
        FactoryGirl.create_list(:task, 21, status: :finished)
        get :index
        expect(assigns(:@finished_tasks)).to be_nil
      end

      it '@user_tasks_in_progressがnilであること' do
        FactoryGirl.create_list(:task, 21, status: :started)
        get :index
        expect(assigns(:@user_tasks_in_progress)).to be_nil
      end

      it 'すべてのユーザのタスクを@all_tasks_in_progresに作成日が新しい順に格納していること' do
        other_users = FactoryGirl.create_list(:user, 5, :with_started_task)
        other_user_tasks_in_progress = Task.where(owner: other_users)
        allow(Task).to receive(:in_progress).and_return(other_user_tasks_in_progress)

        get :index
        expect(assigns(:all_tasks_in_progress)).to match(other_user_tasks_in_progress.order('created_at DESC').to_a)
      end
    end
  end

  describe 'POST #create' do
    context 'ログインしている場合' do
      let(:user) do
        FactoryGirl.build(:user)
      end

      before do
        allow_any_instance_of(TasksController).to receive(:current_user).and_return(user)
      end

      context '入力が有効の場合' do
        it 'root_pathにリダイレクトすること' do
          post :create, task: FactoryGirl.attributes_for(:task)
          expect(response).to redirect_to root_path
        end

        it 'tasksテーブルにレコードを1件追加すること' do
          expect{
            post :create, task: FactoryGirl.attributes_for(:task)
          }.to change(Task, :count).by(1)
        end
      end

      context '入力が無効の場合' do
        it 'Taskモデルのエラーメッセージを引数にしてロギングメソッドを呼び出していること' do
          task = FactoryGirl.build(:task, :invalid_task)
          task.valid?
          allow(controller).to receive(:write_information_log)

          post :create, task: task.attributes
          expect(controller).to have_received(:write_information_log)
            .with(task.errors.full_messages)
        end

        it ':indexテンプレートを表示すること' do
          post :create, task: FactoryGirl.attributes_for(:task, :invalid_task)
          expect(response).to render_template :index
        end

        it 'tasksテーブルにレコードが追加されないこと' do
          expect{
            post :create, task: FactoryGirl.attributes_for(:task, :invalid_task)
          }.not_to change(Task, :count)
        end

        it 'ログインユーザの未着手タスクを@untouched_tasksに作成日が新しい順に格納していること' do
          user.created_tasks << FactoryGirl.build_list(:task, 5, status: :untouched)
          allow(user.created_tasks).to receive(:untouched).and_return(user.created_tasks)

          post :create, task: FactoryGirl.attributes_for(:task, :invalid_task)
          expect(assigns(:untouched_tasks)).to match(user.created_tasks.order('created_at DESC').to_a) 
        end

        it 'ログインユーザの保留タスクを@suspended_tasksに作成日が新しい順に格納していること' do
          user.created_tasks << FactoryGirl.build_list(:task, 5, status: :suspended)
          allow(user.created_tasks).to receive(:suspended).and_return(user.created_tasks)

          post :create, task: FactoryGirl.attributes_for(:task, :invalid_task)
          expect(assigns(:suspended_tasks)).to match(user.created_tasks.order('created_at DESC').to_a) 
        end

        it 'ログインユーザの完了タスクを@finished_tasksに作成日が新しい順に格納していること' do
          user.created_tasks << FactoryGirl.build_list(:task, 5, status: :finished)
          allow(user.created_tasks).to receive(:finished).and_return(user.created_tasks)

          post :create, task: FactoryGirl.attributes_for(:task, :invalid_task)
          expect(assigns(:finished_tasks)).to match(user.created_tasks.order('created_at DESC')) 
        end

        it 'ログインユーザの進行中タスクを@user_tasks_in_progressに作成日が新しい順に格納していること' do
          user.created_tasks << FactoryGirl.build_list(:task, 5, status: :started)
          allow(user.created_tasks).to receive(:in_progress).and_return(user.created_tasks)

          post :create, task: FactoryGirl.attributes_for(:task, :invalid_task)
          expect(assigns(:user_tasks_in_progress)).to match(user.created_tasks.order('created_at DESC').to_a) 
        end

        it 'ログインユーザ以外のすべてのユーザのタスクを@all_tasks_in_progresに作成日が新しい順に格納すること' do
          other_users = FactoryGirl.create_list(:user, 5, :with_started_task)
          other_user_tasks_in_progress = Task.where(owner: other_users)
          FactoryGirl.create(:task, status: :started, owner: user)
          all_tasks_including_logged_in_user = Task.where(owner: other_users << user)
          allow(Task).to receive(:in_progress).and_return(all_tasks_including_logged_in_user)

          post :create, task: FactoryGirl.attributes_for(:task, :invalid_task)
          expect(assigns(:all_tasks_in_progress)).to match(other_user_tasks_in_progress.order('created_at DESC').to_a)
        end
      end
    end
  end
end
