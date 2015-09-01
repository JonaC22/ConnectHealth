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
#

class Patient < ActiveRecord::Base
  include Positionable
  has_one :medical_history
  belongs_to :pedigree
  has_many :patients_diseases
  has_many :diseases, through: :patients_diseases

  # validates :document_number, uniqueness: true
  # validates_length_of :document_number, minimum: 7, maximum: 8
  before_create :create_node

  attr_accessor :diseases

  def create_node
    @node = neo.create_node('id' => @id, 'fecha_nac' => @birth_date, 'nombre' => @name, 'apellido' => @lastname, 'sexo' => @gender)
    neo.add_node_to_index('ind_paciente', 'id', @id, @node)
  end

  def node
    @node ||= Neography::Node.find('ind_paciente', 'id', @id)
  end

  def add_disease(disease_name, disease_diagnostic)
    disease = Disease.find_by_name!(disease_name)
    relationship = neo.create_relationship('PADECE', node, disease.node)
    neo.reset_relationship_properties(relationship, 'edad_diagnostico' => disease_diagnostic)
    diseases.append(disease)
    patients_diseases.find_by_disease(disease).age = disease_diagnostic
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
end
