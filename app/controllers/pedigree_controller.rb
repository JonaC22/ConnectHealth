class PedigreeController < ApplicationController

  # GET /api/pedigree
  def index
    @neo = Neography::Rest.new(ENV['NEO4J'])
    query_busqueda_pacientes = "match (n:PERSONA{nombre:'#{params[:name]}'})-[*]-(n2:PERSONA) return n, n2"
    pacientes = @neo.execute_query(query_busqueda_pacientes)
    personas = Hash.new
    relaciones = Hash.new

    #Se extraen personas y relaciones
    pacientes["data"].each_with_index do |persona,index|
      persona.each do |per|
        p = Person.new( per["metadata"]["id"], per['data']['nombre'])
        personas[p.id] = p
      end
    end

    #Se extraen relaciones
    personas.each_with_index do |persona, index|
      nodo = Neography::Node.load(persona.id,@neo)
      relaciones[index] = nodo.incoming
    end

    result = Hash.new

    result['personas'] =  personas
    result['relations'] = relaciones
    render json:result
  end

#POST /api/pedigree
  def create
  end
end