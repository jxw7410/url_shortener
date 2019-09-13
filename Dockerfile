FROM ruby:2.5.1

RUN bundler -v

RUN apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        postgresql-client \
        nodejs \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists

RUN mkdir /usr/src/app
WORKDIR /usr/src/app 

COPY Gemfile* ./
ENV BUNDLER_VERSION 2.0.1
RUN gem install bundler -v 2.0.1 && bundler -v 
RUN bundle install
COPY . .

CMD puma -C config/puma.rb