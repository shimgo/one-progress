class TasksController < ApplicationController
  before_action :authenticate, except: [:index]

  def create
    @task = current_user.created_tasks.new(task_params)
    if @task.save
      redirect_to root_path, notice: 'タスクを作成しました'
    else
      write_information_log(@task.errors.full_messages)

      @untouched_tasks        = current_user_untouched_tasks
      @suspended_tasks        = current_user_suspended_tasks
      @finished_tasks         = current_user_finished_tasks
      @user_tasks_in_progress = current_user_tasks_in_progress
      @all_tasks_in_progress  = all_tasks_in_progress

      render action: :index
    end
  end

  def destroy
    task = current_user.created_tasks.find(params[:id])
    task.destroy!
    redirect_to root_path, notice: 'タスクを削除しました'
  rescue ActiveRecord::RecordNotFound => e
    write_failure_log(e.message)
    redirect_to root_path, alert: ['タスクが見つかりませんでした']
  end

  def finish
    task = current_user.created_tasks.find(params[:id])
    task.finish
    redirect_to root_path, notice: 'タスクを完了しました'
  rescue ActiveRecord::RecordNotFound => e
    write_failure_log(e.message)
    redirect_to root_path, alert: ['タスクが見つかりませんでした']
  end

  def index
    @untouched_tasks        = current_user_untouched_tasks
    @suspended_tasks        = current_user_suspended_tasks
    @finished_tasks         = current_user_finished_tasks
    @user_tasks_in_progress = current_user_tasks_in_progress
    @all_tasks_in_progress  = all_tasks_in_progress
    @task                   = Task.new
  end

  def resume
    begin
      task = current_user.created_tasks.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      write_failure_log(e.message)
      redirect_to root_path, alert: ['タスクが見つかりませんでした']
      return
    end

    if task.resume
      redirect_to root_path, notice: 'タスクを再開しました'
    else
      write_information_log(task.errors.full_messages)
      redirect_to root_path, alert: task.errors.full_messages
    end
  end

  def start
    begin
      task = current_user.created_tasks.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      write_failure_log(e.message)
      redirect_to root_path, alert: ['タスクが見つかりませんでした']
      return
    end

    if task.start
      redirect_to root_path, notice: 'タスクを開始しました'
    else
      write_information_log(task.errors.full_messages)
      redirect_to root_path, alert: task.errors.full_messages
    end
  end

  def suspend
    task = current_user.created_tasks.find(params[:id])
    task.suspend
    redirect_to root_path, notice: 'タスクを中断しました'
  rescue ActiveRecord::RecordNotFound => e
    write_failure_log(e.message)
    redirect_to root_path, alert: ['タスクが見つかりませんでした']
  end

  def update
    begin
      task = current_user.created_tasks.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      write_failure_log(e.message)
      redirect_to root_path, alert: ['タスクが見つかりませんでした']
      return
    end

    if task.update(task_params)
      flash[:notice] = 'タスクを更新しました'
      head :ok
    else
      write_information_log(task.errors.full_messages)
      render json: { id: task.id, messages: task.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def task_params
    converted_params = params.require(:task).permit(:content, :target_time)
    converted_params[:target_time] = Time.utc(2000, 1, 1, 0, 0, 0) + params[:task][:target_time].to_i
    converted_params
  end

  def all_tasks_in_progress
    Task.in_progress
        .where('user_id <> ?', current_user || '').order('created_at DESC')
        .page(params[:all_tasks_in_progress_page]).per(Settings.all_tasks_per_page)
  end

  def current_user_tasks_in_progress
    return unless current_user
    current_user.created_tasks.in_progress.order('created_at DESC')
  end

  def current_user_finished_tasks
    return unless current_user
    current_user.created_tasks.finished.order('created_at DESC')
                .page(params[:finished_tasks_page])
                .per(Settings.stopped_tasks_per_page)
  end

  def current_user_suspended_tasks
    return unless current_user
    current_user.created_tasks.suspended.order('created_at DESC')
                .page(params[:suspended_tasks_page])
                .per(Settings.stopped_tasks_per_page)
  end

  def current_user_untouched_tasks
    return unless current_user
    current_user.created_tasks.untouched.order('created_at DESC')
                .page(params[:untouched_tasks_page])
                .per(Settings.stopped_tasks_per_page)
  end
end
