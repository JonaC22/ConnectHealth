class Pedigree < ActiveRecord::Base
	has_many :patients
	has_many :annotations
	has_many :queries

	attr_accessor :current_patient


	def initialize(persons = [], relations = [])
		@people = persons
		@relations = relations
	end

	def set_current(person)
		@current_patient = person
	end

	def add(element)
		element.add_to(self)
	end

	def add_person(person)
		@people << person
	end

	def add_relation(relation)
		@relations << relation
	end

	def add_elements(elements)
		elements.each {|element| element.add_to(self)}
	end

	def get_people
		@people
	end

	def to_json
		json = Hash.new
		json['people'] = @people
		json['relations'] = @relations
		json['current'] = current_patient
    json['annotations'] = @annotations
		json
	end
end
>>>>>>> dev
