# == Schema Information
#
# Table name: functions
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#

class Function < ActiveRecord::Base
  has_and_belongs_to_many :roles
  validates :name, presence: true
  before_save do
    description.capitalize!
    name.capitalize!
  end
end
