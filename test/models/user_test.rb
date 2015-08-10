# == Schema Information
#
# Table name: users
#
#  id       :integer          not null, primary key
#  username :string(45)       not null
#  password :string(45)       not null
#  active   :boolean          not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
