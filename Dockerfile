# syntax = docker/dockerfile:1

FROM ruby:3.3.7-slim

# Обновление системы и установка Bundler 2.6.6
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && gem update --system \
    && gem install bundler -v 2.6.6

WORKDIR /app

COPY Gemfile Gemfile.lock ./

# Установка гемов с правильной версией Bundler
RUN bundle _2.6.6_ install --jobs=4 --retry=3

COPY . .

RUN RAILS_ENV=production bundle exec rails assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]























































































































































