# == Schema Information
#
# Table name: role_functions
#
#  id_role     :integer          not null
#  id_function :integer          not null
#

class RoleFunction < ActiveRecord::Base
	belongs_to :role
	belongs_to :function
end
