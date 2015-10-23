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
  has_and_belongs_to_many :roles
end
