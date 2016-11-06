class TasksController < ApplicationController

  def create
    @task = current_user.created_tasks.new(task_params)
    if @task.save
      redirect_to root_path, notice: 'タスクを作成しました'
    else
      redirect_to root_path, alert: @task.errors.full_messages
    end
  end

  def destroy
    @task = current_user.created_tasks.find(params[:id])
    @task.destroy!
    redirect_to root_path, notice: 'タスクを削除しました'
  end

  def finish
    @task = current_user.created_tasks.find(params[:id])
    if @task.finish
      redirect_to root_path, notice: "タスクを完了しました"
    else
      render json: { messages: task.errors.full_messages }, 
        status: :unprocessable_entity
    end
  end
  
  def index
    user = current_user
    if user
      log_in(user)
      @untouched_tasks        = user.created_tasks.untouched
      @suspended_tasks        = user.created_tasks.suspended
      @user_tasks_in_progress = user.created_tasks.in_progress
      @task                   = user.created_tasks.new
    else
      user = User.new
    end

    @all_tasks_in_progress = Task.in_progress.where('user_id <> ?', user.id || '')
  end

  def resume
    @task = current_user.created_tasks.find(params[:id])
    if @task.resume
      redirect_to root_path, notice: 'タスクを再開しました'
    else
      render json: { messages: task.errors.full_messages }, 
        status: :unprocessable_entity
    end
  end

  def start
    @task = current_user.created_tasks.find(params[:id])
    if @task.start
      redirect_to root_path, notice: 'タスクを開始しました'
    else
      render json: { messages: task.errors.full_messages }, 
        status: :unprocessable_entity
    end
  end

  def suspend
    @task = current_user.created_tasks.find(params[:id])
    if @task.suspend
      redirect_to root_path, notice: 'タスクを中断しました'
    else
      render json: { messages: task.errors.full_messages }, 
        status: :unprocessable_entity
    end
  end

  def update
    @task = current_user.created_tasks.find(params[:id])
    if @task.update(task_params)
      flash[:notice] = 'タスクを更新しました'
      head :ok
    else
      render json: { messages: task.errors.full_messages }, 
        status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:content, :target_time)
  end

end
