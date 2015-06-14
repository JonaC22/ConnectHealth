class PedigreeController < BaseController
  before_filter :initialize
  skip_before_filter :verify_authenticity_token
  def initialize
    @neo = Neography::Rest.new(ENV['NEO4J'])
  end
  # GET /api/pedigree
  def index
    query_busqueda_pacientes = "match (n:PERSONA{nombre:'#{params[:name]}'})-[*]-(n2:PERSONA) return n, n2"
    patients = @neo.execute_query(query_busqueda_pacientes)
    persons = Hash.new
    relations = Hash.new

    #Se extraen personas y relaciones
    patients["data"].each_with_index do |person,index|
      person.each do |per|
        p = Person.new( per["metadata"]["id"], per['data']['nombre'], per['data']['sexo'])
        persons[p.id] = p
      end
    end

    #Se extraen relaciones
    persons.each {|key, value| puts 
      node = Neography::Node.load(key, @neo)

      node.rels(:PADRE, :MADRE).outgoing.each { |relat|

        #puts YAML::dump(relat)

        #person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations.store(relations.length, Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.rel_type)) #{:person => value.name, :person_related => relat.nombre}
      }
    }

    result = Hash.new

    result['personas'] =  persons.values
    result['relations'] = relations.values
    render json:result
  end

  before_filter only: :create do
    @json = JSON.parse(request.body.read)
    unless @json.has_key?('personas') && @json.has_key?('relations')
      render nothing: true, status: :bad_request
    end
  end

#POST /api/pedigree
  def create
    persons = Hash.new
    @json['personas'].each { |persona|
      node = @neo.create_node("edad" => persona['edad'], "nombre" => persona['nombre'],'sexo' => persona['sexo'], 'posX' => persona['posX'], 'posY' => persona['posY'])
      @neo.set_label(node,"PERSONA")
      persons[persona['id']] = node
    }
    @json['relations'].each { |rel|
      @neo.create_relationship(rel['name'], persons[rel['from']], persons[rel['to']])
    }
    render json:@json
  end
end