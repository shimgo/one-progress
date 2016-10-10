class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :user,         foreign_key: true, index: true
      t.string     :content,      null: false
      t.time       :target_time,  null: false 
      t.datetime   :elapsed_time
      t.datetime   :start_time
      t.datetime   :end_time

      t.timestamps null: false
    end

  end
end
