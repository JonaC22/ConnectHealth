class Role < ActiveRecord::Base
	has_many :user_role
	has_many :role_function
end
