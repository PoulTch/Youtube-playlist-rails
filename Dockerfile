# syntax = docker/dockerfile:1

FROM ruby:3.3.7-slim

# Установка всех необходимых зависимостей
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    # Базовые утилиты
    curl \
    gnupg \
    ca-certificates \
    # Для native gems
    build-essential \
    pkg-config \
    libpq-dev \
    libyaml-dev \
    libgmp-dev \
    libssl-dev \
    zlib1g-dev \
    # Для Node.js
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install --no-install-recommends -y nodejs \
    # Очистка
    && rm -rf /var/lib/apt/lists/* \
    && gem update --system \
    && gem install bundler -v 2.6.6

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle _2.6.6_ install --jobs=4 --retry=3

COPY . .
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]























































































































































































