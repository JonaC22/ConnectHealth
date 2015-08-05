class RoleFunction < ActiveRecord::Base
	belongs_to :role
	belongs_to :function
end
