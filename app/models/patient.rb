class Patient < ActiveRecord::Base
	has_one :medical_history
end
