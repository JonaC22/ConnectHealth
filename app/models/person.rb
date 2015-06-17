class Person

  attr_accessor :id, :name, :surname, :birth_date, :gender, :medical_history
  @diseases = []

  def initialize(id, name, surname, birth_date, gender, medical_history =nil, diseases = [])
    @id = id
    @name = name
    @surname = surname
    @birth_date = birth_date
    @gender = gender
    @medical_history = medical_history
    @diseases = diseases
  end

  def add_to(pedigree) 
    unless pedigree.get_persons_ids.include? @id
        pedigree.add_person(self)
    end
  end

  def age
      now = Time.now.utc.to_date
      birth = Date.parse(birth_date)
      now.year - birth.year - (birth.to_date.change(:year => now.year) > now ? 1 : 0)
  end

end