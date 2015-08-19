# == Schema Information
#
# Table name: pedigrees
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Pedigree < ActiveRecord::Base
  has_many :patients
  has_many :annotations
  has_many :queries

  attr_accessor :current_patient, :elements, :relations
end
