# == Schema Information
#
# Table name: functions
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Function < ActiveRecord::Base
	has_many :role_function
end
