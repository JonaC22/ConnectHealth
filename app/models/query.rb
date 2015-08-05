class Query < ActiveRecord::Base
	belongs_to :pedigree
	belongs_to :user
end
