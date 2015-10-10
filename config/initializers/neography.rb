neo4j_url = ENV['GRAPHENEDB_URL'] || 'http://localhost:7474' # default to local server

if ENV['ENV'] == 'development'
  uri = URI.parse(ENV['NEO4J_DEV'])
else
  uri = URI.parse('http://app36674657:8Q61OyUC9w6d8jw7qpUb@app36674657.sb05.stations.graphenedb.com:24789')
end

require 'neography'

Neography.configure do |conf|
  conf.server = uri.host
  conf.port = uri.port
  conf.protocol = uri.scheme + '://'
  conf.authentication = 'basic'
  conf.username = uri.user
  conf.password = uri.password
end
