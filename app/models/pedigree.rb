# == Schema Information
#
# Table name: pedigrees
#
#  id          :integer          not null, primary key
#  id_patient  :integer          not null
#  create_date :date             not null
#

class Pedigree < ActiveRecord::Base
  has_many :patients
  has_many :annotations
  has_many :queries

  attr_accessor :current_patient, :elements

  def add_relation(relation)
    @relations << relation
  end

  def add_elements(elements)
    elements.each { |element| element.add_to(self) }
  end

  def to_json
    json = {}
    json['people'] = @people
    json['relations'] = @relations
    json['current'] = current_patient
    json['annotations'] = @annotations
    json
  end
end
