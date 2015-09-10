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
#

class Patient < ActiveRecord::Base
  include Positionable
  has_one :medical_history
  belongs_to :pedigree
  has_many :patient_diseases
  has_many :diseases, through: :patient_diseases
  enum status: {
    unborn: 0,
    alive: 1,
    dead: 2
  }

  # validates :document_number, uniqueness: true
  # validates_length_of :document_number, minimum: 7, maximum: 8
  before_create :create_node

  def create_node
    node ||= neo.create_node('id' => @id, 'fecha_nac' => @birth_date, 'nombre' => @name, 'apellido' => @lastname, 'sexo' => @gender)
    self.neo_id = node['metadata']['id']
    neo.add_node_to_index('ind_paciente', 'id', @id, node)
  end

  def age
    now = Time.now.utc.to_date
    now.year - birth_date.year - (birth_date.to_date.change(year: now.year) > now ? 1 : 0)
  end

  def node
    @node ||= Neography::Node.load(neo_id, neo)
  end

  def add_disease(disease_name, disease_diagnostic)
    disease = Disease.find_by_name!(disease_name)
    relationship = neo.create_relationship('PADECE', node, disease.node)
    neo.reset_relationship_properties(relationship, 'edad_diagnostico' => disease_diagnostic)
    PatientDisease.create! patient: self, disease: disease, age: disease_diagnostic
  end

  def generate_mother(nombre, apellido)
    # fecha_nac=DateTime.strptime(self.birth_date, "%Y-%m-%d %H:%M:%S")
    @mother = Patient.create!(name: nombre, lastname: apellido, birth_date: birth_date - 365 * 10, gender: 'F', pedigree: pedigree, active: true)
    neo.create_relationship('MADRE', node, @mother.node)
    @mother
  end

  def generate_father(nombre)
    @father = Patient.create!(name: nombre, lastname: lastname, birth_date: birth_date - 365 * 11, gender: 'M', pedigree: pedigree, active: true)
    neo.create_relationship('PADRE', node, @father.node)
    @father
  end

  def neo
    @neo ||= Neography::Rest.new
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

  def youngest_age_ec_diagnosis
    # code here
  end

  def youngest_age_crc_diagnosis
    # code here
  end

  def relatives_ls_presence
    # code here
  end

  def relatives_ec_presence
    # code here
  end

  def relatives_crc_presence
    # code here
  end

  def proband_ls_presense
    # code here
  end

  def proband_ec_presence
    # code here
  end

  def proband_crc_presence
    # code here
  end
end
