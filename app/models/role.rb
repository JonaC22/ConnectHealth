# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  description :string(255)
#  active      :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Role < ActiveRecord::Base
	has_many :user_role
	has_many :role_function
end
