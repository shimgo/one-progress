#!/bin/bash
set -e
bundle exec rake db:setup
bundle exec rake assets:precompile
bundle exec rake error_page:gen
export SECRET_KEY_BASE=`bundle exec rake secret -s`
exec "$@"
