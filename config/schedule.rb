# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#
# cronジョブ実行時は環境変数が引き継がれないのでここで渡す
ENV.each{|k,v| env k.to_sym, v}

set :output, "/var/www/one-progress/log/batch.log"

every 1.hours do
  runner "Batches::TaskMaintainer.suspend_tasks"
end
