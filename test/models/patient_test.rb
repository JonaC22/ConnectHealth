# == Schema Information
#
# Table name: patients
#
#  id              :integer          not null, primary key
#  name            :string(45)       not null
#  lastname        :string(45)       not null
#  document_type   :string(10)       not null
#  document_number :integer          not null
#  active          :integer          not null
#  pedigree_id     :integer
#

require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
