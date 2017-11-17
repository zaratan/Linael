FROM ruby:2.4.2
RUN mkdir app
WORKDIR app
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle

ADD ./bin /app/
ADD ./translation /app/
ADD ./config /app/
ADD ./lib /app/

CMD bin/linael
