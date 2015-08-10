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

class Query < ActiveRecord::Base
	belongs_to :pedigree
	belongs_to :user
end
