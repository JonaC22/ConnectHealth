class PedigreeController < ApplicationController

  # GET /api/pedigree
  def index
    @neo = Neography::Rest.new(ENV['NEO4J'])
    query_busqueda_pacientes = "match (n:PERSONA{nombre:'#{params[:name]}'})-[*]-(n2:PERSONA) return n, n2"
    patients = @neo.execute_query(query_busqueda_pacientes)
    persons = Hash.new
    relations = Hash.new

    #Se extraen personas y relaciones
    patients["data"].each_with_index do |person,index|
      person.each do |per|
        p = Person.new( per["metadata"]["id"], per['data']['nombre'])
        persons[p.id] = p
      end
    end

    #Se extraen relaciones
    persons.each {|key, value| puts 
      node = Neography::Node.load(key, @neo)
      node.outgoing.each_with_index { |relat, index|

        #puts YAML::dump(relat.nombre)

        #person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations[index] = {:person => value.name, :person_related => relat.nombre}
      }
    }

    result = Hash.new

    result['personas'] =  persons
    result['relations'] = relations
    render json:result
  end

#POST /api/pedigree
  def create
  end
end