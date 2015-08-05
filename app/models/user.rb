class User < ActiveRecord::Base
	# TODO: agregarle contraseña al usuario
	has_many :queries
	has_many :statistical_reports
	has_many :user_roles
end
