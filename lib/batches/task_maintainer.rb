module Batches
  class TaskMaintainer
    def self.suspend_tasks
      task = Task.in_progress.where(
        "TIMESTAMPDIFF(DAY, IFNULL(resumed_at, started_at), '#{Time.zone.now.to_s(:db)}') > 0"
      ).first
      task.suspend if task
    end
  end  
end
