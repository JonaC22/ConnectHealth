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

      node.rels(:PADRE, :MADRE).outgoing.each { |relat|

        puts YAML::dump(relat)

        #person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations.store(relations.length, Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.end_node.nombre)) #{:person => value.name, :person_related => relat.nombre}
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