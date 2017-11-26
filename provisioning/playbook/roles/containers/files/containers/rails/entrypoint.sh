#!/bin/bash
set -e
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake assets:precompile
bundle exec rake error_page:gen
bundle exec whenever --clear-crontab
bundle exec whenever --update-crontab
export SECRET_KEY_BASE=`bundle exec rake secret -s`
exec "$@"
