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

require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
