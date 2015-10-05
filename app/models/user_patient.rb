# == Schema Information
#
# Table name: user_patients
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  patient_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserPatient < ActiveRecord::Base
end
