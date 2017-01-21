FROM ruby:2.3.1

RUN apt-get update && apt-get install -y nodejs mysql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app
ADD ./Gemfile /opt/app/Gemfile
RUN bundle install -j4 --without development test --path vendor/bundle \
    && bundle exec rails new . -s --skip-bundle 
COPY ./config/unicorn.rb /opt/app/config/unicorn.rb
EXPOSE 3000
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb"]
