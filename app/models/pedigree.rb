class Pedigree
	attr_accessor :id, :current_patient
	@persons = []
	@relations = []

	def initialize(persons = [], relations = [])
		@persons = persons
		@relations = relations
	end

	def add(element)
		element.add_to(self)
	end

	def add_person(person)
		@persons << person
	end

	def add_relation(relation)
		@relations << relation
	end

	def add_elements(elements)
		elements.each {|element| element.add_to(self)}
	end

	def get_persons_ids
		@persons.map {|person| person.id}
	end

	def to_json
		json = Hash.new
		json['persons'] = @persons
		json['relations'] = @relations
		json
	end
end