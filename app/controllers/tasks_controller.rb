class TasksController < ApplicationController

  def create
    @task = current_user.created_tasks.new(task_params)
    if @task.save
      redirect_to root_path, notice: 'タスクを作成しました'
    else
      render root_path
    end
  end

  def index
    user = current_user || User.new

    @all_tasks_in_progress = Task.in_progress
    @untouched_tasks       = user.created_tasks.untouched
    @task                  = user.created_tasks.new
  end

  private

  def task_params
    params.require(:task).permit(:content, :target_time)
  end
end
