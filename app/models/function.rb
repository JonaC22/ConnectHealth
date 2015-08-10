# == Schema Information
#
# Table name: functions
#
#  id          :integer          not null, primary key
#  description :string(45)       not null
#

class Function < ActiveRecord::Base
	has_many :role_function
end
