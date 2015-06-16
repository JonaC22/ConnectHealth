neo4j_url = ENV["GRAPHENEDB_URL"] || "http://localhost:7474" # default to local server

if(ENV["RACK_ENV"] == "development")
	uri = URI.parse(ENV["NEO4J_DEV"])
else
	uri = URI.parse(neo4j_url)
end

require 'neography'

Neography.configure do |conf|
  conf.server = uri.host
  conf.port = uri.port
  conf.protocol = uri.scheme + "://"
  conf.authentication = 'basic'
  conf.username = uri.user
  conf.password = uri.password
end
