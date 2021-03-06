# == Schema Information
#
# Table name: patients
#
#  id              :integer          not null, primary key
#  pedigree_id     :integer
#  name            :string(255)
#  lastname        :string(255)
#  document_type   :string(255)
#  document_number :string(255)
#  active          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  gender          :string(255)
#  birth_date      :date
#  neo_id          :integer
#  status          :integer
#  patient_type    :integer
#
# Indexes
#
#  index_patients_on_neo_id       (neo_id)
#  index_patients_on_pedigree_id  (pedigree_id)
#

class Patient < ActiveRecord::Base
  include Positionable
  include Filterable

  has_one :medical_history
  belongs_to :pedigree
  has_many :patient_diseases
  has_many :diseases, through: :patient_diseases
  has_and_belongs_to_many :users
  enum status: {
    unborn: 0,
    alive: 1,
    dead: 2
  }
  enum patient_type: {
    patient: 0,
    relative: 1
  }

  scope :patient_name, -> (name) { where('name like ? or lastname like ?', "%#{name}%", "%#{name}%") }
  scope :patient_lastname, -> (name) { where('lastname like ?', "%#{name}%") }
  scope :patient_gender, -> (gender) { where(gender: gender) }
  scope :type, -> (type) { where(patient_type: type) }
  VALID_NAME_REGEX = /\A[a-zA-ZñÑ]+( [a-zA-ZñÑ]+)*\z/i
  VALID_DNI_REGEX = /\A[0-9]+\z/
  validates :name, presence: true, format: { with: VALID_NAME_REGEX }
  validates :lastname, presence: true, format: { with: VALID_NAME_REGEX }
  validate :validate_birth_date
  validates :document_number, format: { with: VALID_DNI_REGEX }, allow_blank: true
  validate :validate_document_number_presence
  # validates_length_of :document_number, minimum: 7, maximum: 8
  before_create :create_node
  before_create :set_defaults
  after_create :save_node_to_index
  before_destroy :delete_node

  def create!(params)
    super
  end

  def set_defaults
    self.active = true
    self.status ||= age > 150 ? 'dead' : 'alive'
    return unless document_number
    self.document_type ||= 'dni'
    self.pedigree = Pedigree.create! unless pedigree
  end

  def create_node
    node ||= neo.create_node('edad' => age, 'fecha_nac' => birth_date, 'nombre' => name, 'apellido' => lastname, 'sexo' => gender)
    neo.set_label(node, 'PERSONA')
    self.neo_id = node['metadata']['id']
  end

  def save_node_to_index
    neo.add_node_to_index('patient_index', 'id', id, node)
  end

  def age
    return unless birth_date
    now = Time.now.utc.to_date
    now.year - birth_date.year - (birth_date.to_date.change(year: now.year) > now ? 1 : 0)
  end

  def node
    @node ||= Neography::Node.load(neo_id, neo)
  end

  def add_disease(disease_id, disease_diagnostic)
    disease = Disease.find_by!(id: disease_id)
    return if PatientDisease.find_by(patient: self, disease: disease, age: disease_diagnostic)
    puts disease.inspect
    to_node = disease.node
    from_node = node
    relationship = neo.create_relationship('PADECE', from_node, to_node)
    PatientDisease.create! patient: self, disease: disease, age: disease_diagnostic, neo_id: relationship['metadata']['id']
    neo.reset_relationship_properties(relationship, 'edad_diagnostico' => disease_diagnostic)
  end

  def remove_disease(disease_id, disease_diagnostic)
    disease = Disease.find_by!(id: disease_id)
    pat_dis = PatientDisease.find_by(patient: self, disease: disease, age: disease_diagnostic)
    pat_dis.destroy! if pat_dis
  end

  def validate_relationship(relationship, relation_receiver)
    fail ImposibleRelationException, "The #{relationship} cannot be younger for patient:#{name} and patient:#{relation_receiver.name}" if Relation.decremental?(relationship) && age && relation_receiver.age && age > relation_receiver.age
    fail DuplicatedRelationException, "Duplicated relation: #{relationship} for patient:#{name} and patient:#{relation_receiver.name}" if Relation.unique?(relationship) && node.rel?(:outgoing, relationship)
  end

  def create_relationship(relationship, relation_receiver)
    validate_relationship(relationship, relation_receiver)
    Neography::Relationship.create(relationship, node, relation_receiver.node)
  end

  def generate_mother(params)
    # fecha_nac=DateTime.strptime(self.birth_date, "%Y-%m-%d %H:%M:%S")
    @mother = Patient.create!(name: params[:name], lastname: params[:lastname], birth_date: birth_date - 365 * 10, gender: 'F', pedigree: pedigree, active: true, patient_type: 'relative')
    neo.create_relationship('MADRE', node, @mother.node)
    if rand > 0.5
      disease_name = rand > 0.5 ? 'Cancer de Mama' : 'Cancer de Ovario'
      @mother.add_disease(disease_name, rand(35..70))
    end
    @mother
  end

  def generate_father(params)
    @father = Patient.create!(name: params[:name], lastname: lastname, birth_date: birth_date - 365 * 11, gender: 'M', pedigree: pedigree, active: true, patient_type: 'relative')
    neo.create_relationship('PADRE', node, @father.node)
    @father
  end

  def neo
    @neo ||= Neography::Rest.new
  end

  def delete_all_relationships
    node.rels(:outgoing, 'PADRE').each(&:del)
    node.rels(:outgoing, 'MADRE').each(&:del)
    node.rels(:incoming, 'PADRE').each(&:del)
    node.rels(:incoming, 'MADRE').each(&:del)
  end

  def first_deg_relatives
    # Se obtiene la madre, las hermanas, y las hijas de la paciente
    query = " match (he)-[:PADRE]->(p)<-[:PADRE]-(n)-[:MADRE]->(m)<-[:MADRE]-(he)
              where id(he) <> id(n) and id(n) = #{neo_id}
              return he as nodo
              UNION
              match (n)-[:MADRE]->(m)
              where id(n) = #{neo_id}
              return m as nodo
              UNION
              match (n)<-[:MADRE]-(hi)
              where id(n) = #{neo_id}
              return hi as nodo"

    neo = Neography::Rest.new
    ret = neo.execute_query(query)

    relatives = {}

    ret['data'].each do |data_array|
      data_array.each do |node|
        relative_id = node['metadata']['id']
        n = Neography::Node.load relative_id
        diseases = []
        diseases.push *n.outgoing(:PADECE)
        diseases = diseases.map(&:nombre)
        relatives.store relative_id, diseases
      end
    end

    relatives
  end

  # Se obtiene nodos de padres, hijos y hermanos
  def first_degree_relatives
    query = " // PADRES
              match (n)-[:PADRE|:MADRE]->(padre)
              where id(n)=#{neo_id}
              return padre as nodo
              UNION
              // HERMANOS
              match (hermano)-[:MADRE]->()<-[:MADRE]-(n)-[:PADRE]->()<-[:PADRE]-(hermano)
              where id(n)=#{neo_id}
              return hermano as nodo
              UNION
              // HIJOS
              match (n)<-[:PADRE|:MADRE]-(hijo)
              where id(n)=#{neo_id}
              return hijo as nodo"

    neo = Neography::Rest.new
    ret = neo.execute_query(query)
    relatives = []
    ret['data'].each do |data_array|
      data_array.each do |node|
        relatives.push node['metadata']['id']
      end
    end
    relatives
  end

  # Se obtiene nodos de abuelos, tios, y nietos
  def second_degree_relatives
    query = " // ABUELO
              match (n)-[:PADRE|:MADRE*2]->(abuelo)
              where id(n)=#{neo_id}
              return abuelo as nodo
              UNION
              // NIETOS
              match (n)<-[:PADRE|:MADRE*2]-(nieto)
              where id(n)=#{neo_id}
              return nieto as nodo
              UNION
              // SOBRINOS
              match (hermano)-[:MADRE]->()<-[:MADRE]-(n)-[:PADRE]->()<-[:PADRE]-(hermano),
              (sobrino)-[:PADRE|:MADRE]->(hermano)
              where id(n)=#{neo_id}
              return sobrino as nodo
              UNION
              // TIOS
              match (n)-[:PADRE|:MADRE]->(padre),
              (tio)-[:MADRE]->()<-[:MADRE]-(padre)-[:PADRE]->()<-[:PADRE]-(tio)
              where id(n)=#{neo_id}
              return tio as nodo
              UNION
              // MEDIO HERMANOS
              match (n)-[:PADRE|:MADRE]->()<-[:PADRE|:MADRE]-(mhermano)
              where id(n)=#{neo_id}
              and not (mhermano)-[:MADRE]->()<-[:MADRE]-(n)-[:PADRE]->()<-[:PADRE]-(mhermano)
              return mhermano as nodo"

    neo = Neography::Rest.new
    ret = neo.execute_query(query)
    relatives = []
    ret['data'].each do |data_array|
      data_array.each do |node|
        relatives.push node['metadata']['id']
      end
    end
    relatives
  end

  # Devuelve la edad a la que tuvo el primer hijo nacido vivo, sino tuvo hijos devuelve 0
  def first_live_birth_age
    ret = []
    ret.push *node.incoming(:MADRE)
    birth_ages = []
    patient_age = age
    rel_ids = ret.map(&:neo_id)
    rel_ids.each do |relative_id|
      child = Patient.find_by! neo_id: relative_id
      birth_ages << patient_age - child.age
    end

    if birth_ages.empty?
      0
    else
      birth_ages.min.to_i
    end
  end

  def disease?(name)
    diseases.any? do |disease|
      disease.name == name
    end
  end

  # name is optional
  def diseases_diagnoses(name)
    diagnoses = node.rels(:PADECE).outgoing
    diagnoses = diagnoses.map { |diagnosis| diagnosis }
    diagnoses = diagnoses.select { |diagnosis| diagnosis.end_node.nombre == name } unless name.nil?
    diagnoses
  end

  def validate_birth_date
    errors.add :birth_date, 'The birth date has not happened yet!' unless birth_date && birth_date < Time.now
  end

  def validate_document_number_presence
    errors.add :document_number, 'A patient must have a document number' unless relative? || document_number
  end

  def delete_node
    neo.delete_node!(node)
  end
end
