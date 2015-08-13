# == Schema Information
#
# Table name: patients
#
#  id              :integer          not null, primary key
#  pedigree_id     :integer
#  name            :string(255)
#  lastname        :string(255)
#  document_type   :string(255)
#  document_number :string(255)
#  active          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Patient < ActiveRecord::Base
  include Positionable
  has_one :medical_history
  belongs_to :pedigree

  validates :document_number, uniqueness: true
  validates_length_of :document_number, minimum: 7, maximum: 8

  attr_accessor :diseases
end
