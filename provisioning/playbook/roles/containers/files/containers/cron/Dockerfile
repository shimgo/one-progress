FROM app

RUN apt-get update && apt-get install -y cron --no-install-recommends && rm -rf /var/lib/apt/lists/*
USER rails
RUN bundle exec whenever --clear-crontab
RUN bundle exec whenever --update-crontab
USER root
ENTRYPOINT [""]
CMD ["cron", "-f"]
