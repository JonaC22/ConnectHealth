# == Schema Information
#
# Table name: role_functions
#
#  id          :integer          not null, primary key
#  role_id     :integer
#  function_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class RoleFunction < ActiveRecord::Base
  belongs_to :role
  belongs_to :function
end
