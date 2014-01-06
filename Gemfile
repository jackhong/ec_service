source "https://rubygems.org"

gem "grape"
gem "sidekiq"
gem "sinatra"
gem "eventmachine"

gem "hiredis"
gem "em-synchrony"
gem "redis", :require => ["redis/connection/synchrony", "redis"]

gem "rack-stream"

group :web_server do
  gem "thin"
end

group :development do
  gem "pry"
end

group :test do
  gem "minitest"
  gem "rack-test"
  gem "fakeredis"
end
