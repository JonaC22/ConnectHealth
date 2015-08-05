class Patient < ActiveRecord::Base
	has_one :medical_history
	belongs_to :pedigree
end
