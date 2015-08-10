# == Schema Information
#
# Table name: medical_histories
#
#  id         :integer          not null, primary key
#  patient_id :integer
#  json_text  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MedicalHistory < ActiveRecord::Base
	belongs_to :patient
end
