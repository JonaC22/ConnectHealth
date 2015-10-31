# == Schema Information
#
# Table name: diseases
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  neo_id     :integer
#  gender     :integer
#
# Indexes
#
#  index_diseases_on_neo_id  (neo_id)
#

class Disease < ActiveRecord::Base
  has_many :patient_diseases
  has_many :patients, through: :patient_diseases

  before_save :lower_case_name

  validates :name, presence: true, uniqueness: { case_sentitive: false }
  before_create :create_node
  before_update :validate_patients_dont_exist
  before_destroy :validate_patients_dont_exist
  before_destroy :delete_node
  enum gender: { F: 0, M: 1, B: 2 }

  def validate_patients_dont_exist
    fail PatientsExistException, 'The disease has at least one patient and cannot be modified' unless patients.empty?
  end

  def create_node
    node = neo.create_node('nombre' => name)
    neo.set_label(node, 'ENFERMEDAD')
    neo.add_node_to_index('enfermedad_index', 'nombre', name, node)
    self.neo_id = node['metadata']['id']
  end

  def lower_case_name
    self.name = name.downcase if name_changed?
  end

  def get_node
    query = " match (n:ENFERMEDAD)
              where n.nombre = '#{name}'
              return n "

    neo = Neography::Rest.new
    ret = neo.execute_query(query)

    dis_id = nil

    ret['data'].each do |data_array|
      data_array.each do |node|
        dis_id = node['metadata']['id']
      end
    end

    Neography::Node.load dis_id
  end

  def node
    @node ||= Neography::Node.load(neo_id, neo)
  end

  def neo
    @neo ||= Neography::Rest.new
  end

  def self.generate(enfermedades)
    enfermedades.each do |disease_name|
      next if Disease.find_by_name(disease_name)
      disease = Disease.create! name: disease_name
      disease.create_node
    end
  end

  def delete_node
    neo.delete_node!(node)
  end
end
