class Person
  include Positionable
  attr_accessor :node, :name, :surname, :birth_date, :gender, :medical_history, :diseases
  @diseases = []

  def to_json(options={})
    options[:except] ||= [:children]
    super(options)
  end

  def initialize(id, name, surname, birth_date, gender, medical_history =nil, diseases = [])
    @id = id
    @name = name
    @surname = surname
    @birth_date = birth_date
    @gender = gender
    @medical_history = medical_history
    @diseases = diseases
  end

  #TODO add diseases
  def self.create_from_neo(patient_id, neo)
    node = Neography::Node.load(patient_id, neo)
    patient = Person.new patient_id, node.nombre, node.apellido, node.fecha_nac, node.sexo
    patient.node = node
    patient
  end

  def self.create_from_mysql(paciente)
    Person.new paciente['Nro_Afiliado'],paciente['Nombre'],paciente['Apellido'],DateTime.strptime(paciente['Fecha_Nac'], "%Y-%m-%d %H:%M:%S"),paciente['Sexo']
  end

  def create_father(nombre)
    neo = Neography::Rest.new
    fecha_nac=self.birth_date
    @father=Person.new -1, nombre, self.lastname, rand(Date.civil(fecha_nac.year-50, 1, 1)..Date.civil(fecha_nac.year-25, 12, 31)), 'M'
    neo.create_relationship('PADRE', get_node,@father.get_node)
    @father
  end

  def create_mother(nombre,apellido)
    # fecha_nac=DateTime.strptime(self.birth_date, "%Y-%m-%d %H:%M:%S")
    neo = Neography::Rest.new
    fecha_nac=self.birth_date
    @mother=Person.new -1, nombre, apellido, (rand(Date.civil(fecha_nac.year-40, 1, 1)..Date.civil(fecha_nac.year-17, 12, 31))), 'F'
    neo.create_relationship('MADRE',get_node, @mother.get_node)
    @mother
  end

  def add_to(pedigree) 
    unless pedigree.get_people.include? @id
        pedigree.add_person(self)
    end
  end

  def age
      now = Time.now.utc.to_date
      birth = Date.parse(birth_date)
      now.year - birth.year - (birth.to_date.change(:year => now.year) > now ? 1 : 0)
  end

  def add_disease(disease)
    neo = Neography::Rest.new
    enf_rel=neo.create_relationship('PADECE', get_node, disease.get_node)
    neo.reset_relationship_properties(enf_rel, {'edad_diagnostico' => disease.edad_diagnostico})
    diseases.append(disease)
  end

  def get_node
    unless @node.nil?
      return @node
    end
    neo = Neography::Rest.new
    @node = neo.create_node('fecha_nac' => @birth_date, 'nombre' => @name, 'apellido' => @lastname,'sexo' => @gender)
    neo.set_label(@node, 'PERSONA')
    @node
  end

end