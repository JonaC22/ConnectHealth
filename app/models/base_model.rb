class BaseModel
  attr_accessor :neo, :mysql

  def initialize
    @neo = Neography::Rest.new
  end

  def mysql_connection
    mysql_url = ENV['CLEARDB_DATABASE_URL']

    if ENV['RACK_ENV'] == 'development'
      uri = URI.parse(ENV['MYSQL_DEV'])
    else
      uri = URI.parse(mysql_url)
    end

    @mysql = Mysql2::Client.new(host: uri.host, database: (uri.path || '').split('/')[1], username: uri.user, password: uri.password)
  end

  def close_mysql
    @mysql.close
  end
end
