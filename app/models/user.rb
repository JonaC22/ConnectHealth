# == Schema Information
#
# Table name: users
#
#  id       :integer          not null, primary key
#  username :string(45)       not null
#  password :string(45)       not null
#  active   :boolean          not null
#

class User < ActiveRecord::Base
	# TODO: agregarle contraseña al usuario
	has_many :queries
	has_many :statistical_reports
	has_many :user_roles
end
