# == Schema Information
#
# Table name: queries
#
#  id          :integer          not null, primary key
#  statement   :string(255)
#  description :string(255)
#  result      :string(255)
#  user_id     :integer
#  pedigree_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end