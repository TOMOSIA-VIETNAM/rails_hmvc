# Development & build image for rails_hmvc.
# gemspec uses `git ls-files`; build context must include `.git`.

ARG RUBY_VERSION=3.2.6
FROM ruby:${RUBY_VERSION}-bookworm

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends git sqlite3 && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock rails_hmvc.gemspec ./
COPY lib/rails_hmvc/version.rb lib/rails_hmvc/version.rb

RUN bundle install -j4

COPY . .

CMD ["bundle", "exec", "rake"]
