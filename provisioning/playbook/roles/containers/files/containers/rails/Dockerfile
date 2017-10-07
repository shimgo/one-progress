FROM ruby:2.3.1

RUN apt-get update && apt-get install -y nodejs mysql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/www/one-progress
WORKDIR /var/www/one-progress
ADD ./one-progress/Gemfile Gemfile
ADD ./one-progress/Gemfile.lock Gemfile.lock
RUN bundle install -j4
ADD ./one-progress ./
ADD ./entrypoint.sh ./
RUN chmod a+x ./entrypoint.sh
RUN groupadd rails 
RUN useradd -g rails rails
RUN chown -R rails:rails .
RUN sed -i -e 's/\(socket.*=\)/#\1/g' /etc/mysql/my.cnf
ENTRYPOINT ["./entrypoint.sh"]
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb"]
