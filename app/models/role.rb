# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  description :string(255)
#  active      :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :functions
  validates :description, presence: true, uniqueness: { case_sentitive: false }, allow_nil: false
  before_save do
    description.capitalize!
    name.capitalize!
  end
end
