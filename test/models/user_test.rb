# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  password_digest :string(255)
#  active          :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  remember_digest :string(255)
#  email           :string(255)
#  photo_url       :string(255)
#  display_name    :string(255)
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
