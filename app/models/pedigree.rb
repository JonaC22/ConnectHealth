class Pedigree < ActiveRecord::Base
	has_many :patients
	has_many :annotations
	has_many :queries
end
