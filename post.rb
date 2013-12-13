require 'securerandom'
require 'base64'
require 'json'

oedl = Base64.encode64(File.read(ARGV[0]))

data = { name: 'bob',
         oedl: oedl,
         props: { res1: 'interlagos' }
}.to_json

cmd = "curl -X POST -H 'Content-Type: application/json' -d '#{data}' http://localhost:3000/experiments"
puts `#{cmd}`
