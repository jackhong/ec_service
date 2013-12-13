gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'
require 'minitest/mock'
require 'rack/test'
require 'fakeredis'
require 'sidekiq'
require 'sidekiq/testing'
require 'json'
require 'pry'
require './helper/redis'

Sidekiq::Testing.fake!
