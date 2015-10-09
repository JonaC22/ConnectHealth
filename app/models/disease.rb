# == Schema Information
#
# Table name: diseases
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Disease < ActiveRecord::Base
  has_many :patient_diseases
  has_many :patients, through: :patient_diseases

  before_save :lower_case_name

  validates :name, presence: true, uniqueness: { case_sentitive: false }

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

  #TODO ARREGLAR, NO FUNCIONA BIEN
  def node
    @node = Neography::Node.find('enfermedad_index', 'nombre', name)
  rescue Neography::NeographyError => err
    puts err.message
    @node = neo.create_node('nombre' => name)
    neo.set_label(@node, 'ENFERMEDAD')
    neo.add_node_to_index('enfermedad_index', 'nombre', name, @node)
    return @node
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

  def create_node
    @node = neo.create_node('nombre' => name)
    neo.set_label(@node, 'ENFERMEDAD')
    neo.add_node_to_index('enfermedad_index', 'nombre', name, @node)
  end
end
