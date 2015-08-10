# == Schema Information
#
# Table name: statistical_reports
#
#  id          :integer          not null, primary key
#  create_date :date             not null
#  query       :string(1000)     not null
#  description :string(45)       not null
#  result      :string(1000)     not null
#  made_by     :integer          not null
#

class StatisticalReport < ActiveRecord::Base
	belongs_to :user
end
