class Person

  attr_accessor :id, :name, :surname, :birth_date, :gender, :medical_history,:diseases
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

  def self.create_from_mysql(paciente)
    persona = Person.new paciente['Nro_Afiliado'],paciente['Nombre'],paciente['Apellido'],DateTime.strptime(paciente['Fecha_Nac'], "%Y-%m-%d %H:%M:%S"),paciente['Sexo']
    return persona
  end

  def create_father(nombre)
    fecha_nac=self.birth_date
    Person.new -1, nombre, self.surname, rand(Date.civil(fecha_nac.year-50, 1, 1)..Date.civil(fecha_nac.year-25, 12, 31)), 'm'
  end

  def create_mother(nombre,apellido)
    # fecha_nac=DateTime.strptime(self.birth_date, "%Y-%m-%d %H:%M:%S")
    fecha_nac=self.birth_date
    Person.new -1, nombre, apellido, (rand(Date.civil(fecha_nac.year-40, 1, 1)..Date.civil(fecha_nac.year-17, 12, 31))), 'f'
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