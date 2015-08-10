# == Schema Information
#
# Table name: queries
#
#  id          :integer          not null, primary key
#  create_date :date             not null
#  query       :string(1000)     not null
#  description :string(45)       not null
#  result      :string(1000)     not null
#  made_by     :integer          not null
#  id_pedigree :integer          not null
#

require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
