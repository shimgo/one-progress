FROM app

RUN apt-get update && apt-get install -y cron --no-install-recommends && rm -rf /var/lib/apt/lists/*
WORKDIR /var/www/one-progress
ADD ./cron.sh ./
RUN chmod a+x ./cron.sh

ENTRYPOINT [""]
CMD ["./cron.sh"]
