gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'
require 'minitest/mock'
require 'rack/test'
require 'fakeredis'
require 'sidekiq'
require 'sidekiq/testing'

require 'grape'
require 'base64'
require 'json'
require 'pry'

Sidekiq::Testing.fake!
I18n.enforce_available_locales = false
