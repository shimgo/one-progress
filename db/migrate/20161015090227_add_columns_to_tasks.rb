class AddColumnsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :status, :integer, after: :user_id, not_null: true, index: true
    add_column :tasks, :suspended_at, :datetime, after: :elapsed_time
    add_column :tasks, :resumed_at, :datetime, after: :suspended_at
    add_column :tasks, :finish_targeted_at, :datetime, after: :finished_at
  end
end
