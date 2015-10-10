# == Schema Information
#
# Table name: statistical_reports
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  statement   :string(255)
#  description :string(255)
#  result      :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class StatisticalReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
