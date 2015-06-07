class PedigreeController < ApplicationController

  # GET /api/pedigree
  def index
    neo = Neography::Rest.new(ENV['NEO4J'])
    query_busqueda_pacientes = "match (n{nombre:'#{params[:name]}'})-[rel]-(n2:PERSONA) return n, n2,rel"
    pacientes = neo.execute_query(query_busqueda_pacientes)
    personas = Hash.new
    relaciones = Hash.new
    # personas << Person.new(4,params[:name])
    pacientes["data"].each_with_index do |persona,index|
      p0 = Person.new(persona[0]["metadata"]["id"],persona[0]["data"]["nombre"])
      p1 =Person.new(persona[1]['metadata']["id"],persona[1]["data"]["nombre"])
      personas[p0.id] =  p0
      personas[p1.id] =  p1
      relaciones[persona[2]['metadata']['id']] = Relation.new(p0.id,p1.id,persona[2]['metadata']['type'])
    end
    #p1 = Person.new(params[:name],Person.new('Luis'),Person.new('Vilma'))
    result = Hash.new
    result['personas'] =  personas
    result['relations'] = relaciones
    render json:result
  end

#POST /api/pedigree
  def create
  end
end