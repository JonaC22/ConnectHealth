class Person < Positionable

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
    @age = age
    @gender = gender
    @medical_history = medical_history
    @diseases = diseases
  end

  def self.create_from_neo patient_id
    node = Neography::Node.load patient_id
    patient = Person.new patient_id, node.nombre, node.apellido, node.fecha_nac, node.sexo
    patient.node = node

    diseases = []
    diseases.push *node.outgoing(:PADECE)
    diseases = diseases.map {|d| d.nombre}
    patient.diseases.push *diseases

    patient
  end

  def self.create_from_mysql(paciente)
    Person.new paciente['Nro_Afiliado'],paciente['Nombre'],paciente['Apellido'],DateTime.strptime(paciente['Fecha_Nac'], "%Y-%m-%d %H:%M:%S"),paciente['Sexo']
  end

  def create_father(nombre)
    neo = Neography::Rest.new
    fecha_nac=self.birth_date
    @father=Person.new -1, nombre, self.surname, rand(Date.civil(fecha_nac.year-50, 1, 1)..Date.civil(fecha_nac.year-25, 12, 31)), 'M'
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
    @node = neo.create_node('fecha_nac' => @birth_date, 'nombre' => @name, 'apellido' => @surname,'sexo' => @gender)
    neo.set_label(@node, 'PERSONA')
    @node
  end

  #Devuelve un par clave-valor, donde la clave es el id del pariente y el valor un array de nombres de enfermedades padecidas.
  def get_first_deg_relatives

    if @node.nil?
      get_node
    end

    ret = []
    #Se obtiene la madre y las hermanas de la paciente
    query = " match (h)-[:PADRE]->(p)<-[:PADRE]-(n)-[:MADRE]->(m)<-[:MADRE]-(h)
              where id(h) <> id(n) and id(n) = #{@id}
              return h as nodo
              UNION
              match (n)-[:MADRE]->(m)
              where id(n) = #{@id}
              return m as nodo"

    neo = Neography::Rest.new
    ret = neo.execute_query(query)

    relatives = {}

    ret['data'].each do |data_array|
      data_array.each do |node|
        relative_id = node['metadata']['id']
        n = Neography::Node.load relative_id
        diseases = []
        diseases.push *n.outgoing(:PADECE)
        diseases = diseases.map {|d| d.nombre}
        relatives.store relative_id, diseases
      end
    end

    relatives
  end

  #Devuelve la edad a la que tuvo el primer hijo nacido vivo, sino tuvo hijos devuelve 0
  def get_first_live_birth_age

    if @node.nil?
      get_node
    end

    ret = []
    ret.push *@node.incoming(:MADRE)

    birth_ages = []
    patient_age = age
    rel_ids = ret.map{|rel| rel.neo_id}
    rel_ids.each do |relative_id|
      child = Person::create_from_neo relative_id
      birth_ages.push (patient_age - child.age)
    end

    if birth_ages.empty?
      0
    else
      birth_ages.min
    end

  end

end