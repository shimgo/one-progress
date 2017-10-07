class RenameColumnsToTasks < ActiveRecord::Migration
  def change
    rename_column :tasks, :start_time, :started_at
    rename_column :tasks, :end_time, :finished_at
  end
end
