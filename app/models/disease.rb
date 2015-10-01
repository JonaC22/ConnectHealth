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

  validates :name, uniqueness: true

  def lower_case_name
    self.name = name.downcase if name_changed?
  end

  def node
    @node = Neography::Node.find('enfermedad_index', 'nombre', @nombre)
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
