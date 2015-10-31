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
# Indexes
#
#  index_statistical_reports_on_user_id  (user_id)
#

class StatisticalReport < ActiveRecord::Base
  belongs_to :user
end
