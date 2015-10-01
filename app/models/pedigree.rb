# == Schema Information
#
# Table name: pedigrees
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Pedigree < ActiveRecord::Base
  has_many :patients, dependent: :destroy
  has_many :annotations, dependent: :destroy
  has_many :queries, dependent: :destroy

  attr_accessor :current_patient, :elements, :relations
end
