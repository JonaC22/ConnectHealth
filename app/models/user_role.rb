# == Schema Information
#
# Table name: user_roles
#
#  id_user :integer          not null
#  id_role :integer          not null
#

class UserRole < ActiveRecord::Base
	belongs_to :user
	belongs_to :role
end
