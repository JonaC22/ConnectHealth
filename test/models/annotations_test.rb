# == Schema Information
#
# Table name: annotations
#
#  id          :integer          not null, primary key
#  id_pedigree :integer          not null
#  pos_x       :string(45)       not null
#  pos_y       :string(45)       not null
#  text        :string(1000)     not null
#

require 'test_helper'

class AnnotationsTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
