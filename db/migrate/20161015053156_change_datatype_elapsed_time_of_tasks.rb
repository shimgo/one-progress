class ChangeDatatypeElapsedTimeOfTasks < ActiveRecord::Migration
  def change
    change_column :tasks, :elapsed_time, :time
  end
end
