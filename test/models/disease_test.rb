# == Schema Information
#
# Table name: diseases
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  neo_id     :integer
#
# Indexes
#
#  index_diseases_on_neo_id  (neo_id)
#

require 'test_helper'

class DiseaseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
