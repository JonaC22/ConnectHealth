class PedigreeController < BaseController

  before_filter :initialize
  skip_before_filter :verify_authenticity_token

  def initialize
    @neo = Neography::Rest.new
  end

  # GET /api/pedigree
  def index
    query_busqueda_pacientes = "match (n:PERSONA{nombre:'#{params[:name]}'})-[*]-(n2:PERSONA) return n, n2"
    patients = @neo.execute_query(query_busqueda_pacientes)
    persons = []
    relations = []
    pedigree = Pedigree.new

    #Se extraen personas y relaciones
    patients["data"].each do |data_array|
      data_array.each do |node|
        person = Person.new( node["metadata"]["id"], node['data']['nombre'], node['data']['sexo'])
        pedigree.add(person)
      end
    end

    #Se extraen relaciones
    pedigree.get_persons_ids.each {|key|
      node = Neography::Node.load(key, @neo)

      node.rels(:PADRE, :MADRE).outgoing.each { |relat|

        #person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations << Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.rel_type)
      }
    }

    pedigree.add_elements(relations)

    #puts YAML::dump(pedigree)

    render json:pedigree.to_json
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
      count = @json['relations'].count{|rel| rel['from'] == persona['id'] && rel['name'] =='MADRE'}
      if count>1
        error=Resultado.new('Relacion MADRE duplicada',500)
        render json:error
        return
      end
    }
    
    @json['relations'].each { |rel|
      @neo.create_relationship(rel['name'], persons[rel['from']], persons[rel['to']])
    }

    resultado= Resultado.new('Pedigree ingresado exitosamente',200)
    render json:resultado
  end

end