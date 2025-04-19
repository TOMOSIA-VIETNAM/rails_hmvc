rm -rf example && rails new example --api --skip-git --skip-javascript
cd example
bundle add rails_hmvc --path ".."
bundle install --path vendor/bundle
bundle info rails_hmvc && bundle exec rails g | grep rails_hmvc
rails g rails_hmvc:init --force --no-stdin
