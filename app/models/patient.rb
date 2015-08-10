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

class Patient < ActiveRecord::Base
  include Positionable
  has_one :medical_history
  belongs_to :pedigree

end
