class ChangeColumnNullToTasks < ActiveRecord::Migration
  def change
    change_column_null :tasks, :elapsed_time, true
  end
end
