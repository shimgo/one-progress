#!/bin/bash

bundle exec whenever --clear-crontab
bundle exec whenever --update-crontab
cron -f

