neo4j_url = ENV["NEO4J"] || "http://localhost:7474" # default to local server

uri = URI.parse(neo4j_url)

require 'neography'

Neography.configure do |conf|
  conf.server = uri.host
  conf.port = uri.port
  conf.protocol = uri.scheme + "://"
  conf.authentication = 'basic'
  conf.username = uri.user
  conf.password = uri.password
end
