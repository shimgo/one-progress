require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  describe '#before_action' do
    before do
      allow(controller).to receive(:authenticate)
    end

    let(:user) do
      FactoryGirl.create(:user, :with_untouched_task)
    end

    it '#createアクション実行時にauthenticateを呼び出すこと' do
      allow(controller).to receive(:current_user).and_return(user)
      post :create, task: FactoryGirl.attributes_for(:task)
      expect(controller).to have_received(:authenticate)
    end

    it '#destroyアクション実行時にauthenticateを呼び出すこと' do
      task = FactoryGirl.create(:task)
      allow(controller).to receive_message_chain(:current_user, :created_tasks)
        .and_return(Task.where(id: task))
      delete :destroy, id: task
      expect(controller).to have_received(:authenticate)
    end

    it '#finishアクション実行時にauthenticateを呼び出すこと' do
      task = FactoryGirl.create(:task, :started_task)
      allow(controller).to receive_message_chain(:current_user, :created_tasks)
        .and_return(Task.where(id: task))
      patch :finish, id: task
      expect(controller).to have_received(:authenticate)
    end

    it '#indexアクション実行時にauthenticateを呼び出さないこと' do
      allow(controller).to receive(:current_user).and_return(user)
      get :index
      expect(controller).not_to have_received(:authenticate)
    end

    it '#resumeアクション実行時にauthenticateを呼び出すこと' do
      task = FactoryGirl.create(:task, :suspended_task)
      allow(controller).to receive_message_chain(:current_user, :created_tasks)
        .and_return(Task.where(id: task))
      patch :resume, id: task
      expect(controller).to have_received(:authenticate)
    end

    it '#startアクション実行時にauthenticateを呼び出すこと' do
      task = FactoryGirl.create(:task)
      allow(controller).to receive_message_chain(:current_user, :created_tasks)
        .and_return(Task.where(id: task))
      patch :start, id: task
      expect(controller).to have_received(:authenticate)
    end

    it '#suspendアクション実行時にauthenticateを呼び出すこと' do
      task = FactoryGirl.create(:task, :started_task)
      allow(controller).to receive_message_chain(:current_user, :created_tasks)
        .and_return(Task.where(id: task))
      patch :suspend, id: task
      expect(controller).to have_received(:authenticate)
    end

    it '#updateアクション実行時にauthenticateを呼び出すこと' do
      task = FactoryGirl.create(:task)
      allow(controller).to receive_message_chain(:current_user, :created_tasks)
        .and_return(Task.where(id: task))
      patch :update, id: task, task: task.attributes
      expect(controller).to have_received(:authenticate)
    end
  end

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

  describe 'DELETE #destroy' do
    context 'ログインしている場合' do
      let(:user) do
        FactoryGirl.build(:user)
      end

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      context '指定したタスクが存在している場合' do
        it 'root_pathにリダイレクトすること' do
          task = FactoryGirl.create(:task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))

          delete :destroy, id: task
          expect(response).to redirect_to root_path
        end

        it 'flash[:notice]に\'タスクを削除しました\'メッセージをセットすること' do
          task = FactoryGirl.create(:task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))

          delete :destroy, id: task
          expect(flash[:notice]).to eq 'タスクを削除しました'
        end

        it 'tasksテーブルからレコードを1件削除すること' do
          task = FactoryGirl.create(:task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))
          expect{delete :destroy, id: task}.to change(Task, :count).by(-1)
        end
      end

      context '指定したタスクが存在しない場合' do
        it 'flash[:alert]に\'タスクが見つかりませんでした\'メッセージを含む配列がセットされること' do
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))
          delete :destroy, id: 9999
          expect(flash[:alert]).to eq ['タスクが見つかりませんでした']
        end

        it 'root_pathにリダイレクトすること' do
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))
          delete :destroy, id: 9999
          expect(response).to redirect_to root_path
        end

        it 'ActiveRecord::RecordNotFound例外のメッセージを引数にしてwrite_failure_logメソッドを呼び出していること' do
          allow(controller).to receive(:write_failure_log)
          allow_any_instance_of(ActiveRecord::RecordNotFound)
            .to receive(:message).and_return('messages')
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          delete :destroy, id: 9999
          expect(controller).to have_received(:write_failure_log).with('messages')
        end
      end
    end
  end

  describe 'PATCH #finish' do
    context 'ログインしている場合' do
      let(:user) do
        FactoryGirl.build(:user)
      end

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      context '指定したタスクが存在している場合' do
        it 'root_pathにリダイレクトすること' do
          task = FactoryGirl.create(:task, :started_task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))

          patch :finish, id: task
          expect(response).to redirect_to root_path
        end

        it 'flash[:notice]に\'タスクをを完了しました\'メッセージをセットすること' do
          task = FactoryGirl.create(:task, :started_task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))

          patch :finish, id: task
          expect(flash[:notice]).to eq 'タスクを完了しました'
        end

        it 'Task#finishメソッドを呼び出すこと' do
          task = FactoryGirl.create(:task, :started_task)
          task_mock = Task.find(task)
          allow(task_mock).to receive(:finish)
          allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
            .and_return(task_mock)

          patch :finish, id: task
          expect(task_mock).to have_received(:finish)
        end
      end

      context '指定したタスクが存在しない場合' do
        it 'flash[:alert]に\'タスクが見つかりませんでした\'メッセージを含む配列がセットされること' do
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :finish, id: 9999
          expect(flash[:alert]).to eq ['タスクが見つかりませんでした']
        end

        it 'root_pathにリダイレクトすること' do
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :finish, id: 9999
          expect(response).to redirect_to root_path
        end

        it 'ActiveRecord::RecordNotFound例外のメッセージを引数にしてwrite_failure_logメソッドを呼び出していること' do
          allow(controller).to receive(:write_failure_log)
          allow_any_instance_of(ActiveRecord::RecordNotFound)
            .to receive(:message).and_return('messages')
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :finish, id: 9999
          expect(controller).to have_received(:write_failure_log).with('messages')
        end
      end
    end
  end

  describe 'PATCH #resume' do
    context 'ログインしている場合' do
      context '指定したタスクが存在している場合' do
        it 'root_pathにリダイレクトすること' do
          task = FactoryGirl.create(:task, :suspended_task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))

          patch :resume, id: task
          expect(response).to redirect_to root_path
        end

        it 'flash[:notice]に\'タスクを再開しました\'メッセージをセットすること' do
          task = FactoryGirl.create(:task, :suspended_task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))

          patch :resume, id: task
          expect(flash[:notice]).to eq 'タスクを再開しました'
        end

        it 'Task#resumeメソッドを呼び出すこと' do
          task = FactoryGirl.create(:task, :suspended_task)
          task_mock = Task.find(task)
          allow(task_mock).to receive(:resume)
          allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
            .and_return(task_mock)

          patch :resume, id: task
          expect(task_mock).to have_received(:resume)
        end

        context '既に作業中のタスクがある場合' do
          before do
            FactoryGirl.create(:task, :started_task)
          end

          let(:task) do
            task = FactoryGirl.create(:task, :suspended_task)
            allow(task).to receive_message_chain(:errors, :full_messages).and_return(['messages'])
            allow(task).to receive(:resume).and_return(false)
            task
          end

          it 'root_pathにリダイレクトすること' do
            allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
              .and_return(task)

            patch :resume, id: task
            expect(response).to redirect_to root_path
          end

          it 'flash[:alert]にタスクのエラーメッセージがセットされること' do
            allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
              .and_return(task)

            patch :resume, id: 9999
            expect(flash[:alert]).to eq(task.errors.full_messages)
          end

          it 'Taskモデルのエラーメッセージを引数にしてwrite_information_logメソッドを呼び出していること' do
            allow(controller).to receive(:write_information_log)
            allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
              .and_return(task)

            patch :resume, id: 9999
            expect(controller).to have_received(:write_information_log).with(task.errors.full_messages)
          end
        end
      end

      context '指定したタスクが存在しない場合' do
        it 'flash[:alert]に\'タスクが見つかりませんでした\'メッセージを含む配列がセットされること' do
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :resume, id: 9999
          expect(flash[:alert]).to eq ['タスクが見つかりませんでした']
        end

        it 'root_pathにリダイレクトすること' do
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :resume, id: 9999
          expect(response).to redirect_to root_path
        end

        it 'ActiveRecord::RecordNotFound例外のメッセージを引数にしてwrite_failure_logメソッドを呼び出していること' do
          allow(controller).to receive(:write_failure_log)
          allow_any_instance_of(ActiveRecord::RecordNotFound)
            .to receive(:message).and_return('messages')
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :resume, id: 9999
          expect(controller).to have_received(:write_failure_log).with('messages')
        end
      end
    end
  end

  describe 'PATCH #start' do
    context 'ログインしている場合' do
      context '指定したタスクが存在している場合' do
        it 'root_pathにリダイレクトすること' do
          task = FactoryGirl.create(:task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))

          patch :start, id: task
          expect(response).to redirect_to root_path
        end

        it 'flash[:notice]に\'タスクを開始しました\'メッセージをセットすること' do
          task = FactoryGirl.create(:task)
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: task))

          patch :start, id: task
          expect(flash[:notice]).to eq 'タスクを開始しました'
        end

        it 'Task#startメソッドを呼び出すこと' do
          task = FactoryGirl.create(:task)
          allow(task).to receive(:start)
          allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
            .and_return(task)

          patch :start, id: task
          expect(task).to have_received(:start)
        end

        context '既に作業中のタスクがある場合' do
          before do
            FactoryGirl.create(:task, :started_task)
          end

          let(:task) do
            task = FactoryGirl.create(:task)
            allow(task).to receive_message_chain(:errors, :full_messages).and_return(['messages'])
            allow(task).to receive(:start).and_return(false)
            task
          end

          it 'root_pathにリダイレクトすること' do
            allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
              .and_return(task)

            patch :start, id: task
            expect(response).to redirect_to root_path
          end

          it 'flash[:alert]にタスクのエラーメッセージがセットされること' do
            allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
              .and_return(task)

            patch :start, id: 9999
            expect(flash[:alert]).to eq(task.errors.full_messages)
          end

          it 'Taskモデルのエラーメッセージを引数にしてwrite_information_logメソッドを呼び出していること' do
            allow(controller).to receive(:write_information_log)
            allow(controller).to receive_message_chain(:current_user, :created_tasks, :find)
              .and_return(task)

            patch :start, id: 9999
            expect(controller).to have_received(:write_information_log).with(task.errors.full_messages)
          end
        end
      end

      context '指定したタスクが存在しない場合' do
        it 'flash[:alert]に\'タスクが見つかりませんでした\'メッセージを含む配列がセットされること' do
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :start, id: 9999
          expect(flash[:alert]).to eq ['タスクが見つかりませんでした']
        end

        it 'root_pathにリダイレクトすること' do
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :start, id: 9999
          expect(response).to redirect_to root_path
        end

        it 'ActiveRecord::RecordNotFound例外のメッセージを引数にしてwrite_failure_logメソッドを呼び出していること' do
          allow(controller).to receive(:write_failure_log)
          allow_any_instance_of(ActiveRecord::RecordNotFound)
            .to receive(:message).and_return('messages')
          allow(controller).to receive_message_chain(:current_user, :created_tasks)
            .and_return(Task.where(id: 9999))

          patch :start, id: 9999
          expect(controller).to have_received(:write_failure_log).with('messages')
        end
      end
    end
  end
end
