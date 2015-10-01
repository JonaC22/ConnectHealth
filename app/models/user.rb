# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  username        :string(255)
#  password_digest :string(255)
#  active          :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ActiveRecord::Base
  # TODO: agregarle contraseña al usuario
  has_many :queries
  has_many :statistical_reports
  has_many :user_roles
  validates :username, presence: true, uniqueness: { case_sentitive: false }
end
