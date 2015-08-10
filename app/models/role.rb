# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  description :string(45)       not null
#  active      :integer          not null
#

class Role < ActiveRecord::Base
	has_many :user_role
	has_many :role_function
end
