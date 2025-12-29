# syntax = docker/dockerfile:1

# Этап сборки
FROM ruby:3.3.7-slim AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    pkg-config \
    curl \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && \
    bundle install --jobs=4 --retry=3

COPY . .

# Для Rails 8 с importmaps/esbuild
RUN if [ -f "package.json" ]; then npm ci; fi

# Для сборки JS (если используется)
RUN if [ -f "esbuild.config.js" ]; then npm run build; fi

RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Production этап
FROM ruby:3.3.7-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libpq5 \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]












































































