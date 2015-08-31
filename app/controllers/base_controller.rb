class BaseController < ApplicationController
  # include ActionController::Serialization # sirve para decirle que es lo que se va a usar cuando devuelva el json
  before_filter :initialize

  attr_accessor :neo, :mysql

  def initialize
    @neo ||= Neography::Rest.new ENV['NEO4J']
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

  def routing_error
    render json: { error: 'resource not found' }, status: params[:path].to_i == 0 ? :not_found : params[:path].to_i
  end

  def close_mysql
    @mysql.close
  end
end
