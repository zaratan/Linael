FROM ruby:2.4.2
RUN mkdir app
WORKDIR app
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle

COPY ./bin /app/bin
COPY ./translation /app/translation
COPY ./config /app/config
COPY ./lib /app/lib

CMD bin/start.rb
