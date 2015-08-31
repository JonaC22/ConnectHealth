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
#  node            :string(255)
#

class Patient < ActiveRecord::Base
  include Positionable
  has_one :medical_history
  belongs_to :pedigree

  # validates :document_number, uniqueness: true
  # validates_length_of :document_number, minimum: 7, maximum: 8
  before_create :create_node

  attr_accessor :diseases

  def create_node
    node = neo.create_node('id' => @id, 'fecha_nac' => @birth_date, 'nombre' => @name, 'apellido' => @lastname, 'sexo' => @gender)
    neo.add_node_to_index('ind_paciente', 'id', @id, node)
  end

  def node
    @node = Neography::Node.find('ind_paciente', 'id', @id)
  end

  def add_disease(disease)
    neo = Neography::Rest.new
    enf_rel = neo.create_relationship('PADECE', get_node, disease.get_node)
    neo.reset_relationship_properties(enf_rel, 'edad_diagnostico' => disease.edad_diagnostico)
    diseases.append(disease)
  end

  def create_mother(nombre, apellido)
    # fecha_nac=DateTime.strptime(self.birth_date, "%Y-%m-%d %H:%M:%S")
    neo = Neography::Rest.new
    @mother = Patient.create! name: nombre, lastname: apellido, gender: 'F'
    neo.create_relationship('MADRE', get_node, @mother.get_node)
    @mother
  end

  def create_father(nombre)
    neo = Neography::Rest.new
    @mother = Patient.create! name: nombre, gender: 'M'
    neo.create_relationship('PADRE', get_node, @father.get_node)
    @father
  end

  def neo
    @neo ||= Neography::Rest.new ENV['NEO4J']
  end
end
