class PedigreeController < BaseController

  attr_accessor :pedigree 

  before_filter :initialize
  skip_before_filter :verify_authenticity_token

  def initialize
    @neo = Neography::Rest.new
  end

  # GET /api/pedigree
  def index
    current_patient_name = params[:name]
    visualize current_patient_name
  end

  def visualize current_patient_name
    query_busqueda_pacientes = 
    "match (n:PERSONA{nombre:'#{current_patient_name}'})-[r:PADRE|MADRE*]-(n2:PERSONA)
    return n2 as nodo
    UNION
    match(n:PERSONA{nombre:'#{current_patient_name}'})
    return n as nodo"
    patients = @neo.execute_query query_busqueda_pacientes
    persons = []
    relations = []
    @pedigree = Pedigree.new

    #Se extraen personas y relaciones
    patients["data"].each do |data_array|
      data_array.each do |node|
        data = node['data']
        person = Person.new node["metadata"]["id"], data['nombre'], data['apellido'], data['fecha_nacimiento'], data['sexo']
        @pedigree.add person
        if person.name == current_patient_name 
          @pedigree.set_current person
        end
      end
    end

    #Se extraen relaciones
    @pedigree.get_persons_ids.each {|key|
      node = Neography::Node.load(key, @neo)

      node.rels(:PADRE, :MADRE).outgoing.each { |relat|

        #person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations << Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.rel_type)
      }
    }

    @pedigree.add_elements relations

    #puts YAML::dump(pedigree)

    render json:@pedigree.to_json
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
      tags = ['MADRE', 'PADRE']
      error = validate_relations @json, persona, tags
      if error.err_number == 500
        return render json:error
      end
      node = @neo.create_node("edad" => persona['edad'], "nombre" => persona['nombre'],'sexo' => persona['sexo'], 'posX' => persona['posX'], 'posY' => persona['posY'])
      @neo.set_label(node,"PERSONA")
      persons[persona['id']] = node
    }
    
    @json['relations'].each { |rel|
      @neo.create_relationship(rel['name'], persons[rel['from']], persons[rel['to']])
    }

    resultado= Resultado.new('Pedigree ingresado exitosamente',200)
    render json:resultado
  end

  def validate_relations json, persona, tags
    tags.each do |tag|
      count = json['relations'].count{|rel| rel['from'] == persona['id'] && rel['name'] == tag}
      if count > 1
        return Resultado.new("Relacion duplicada: #{tag}", 500)
      end
    end
    Resultado.new('OK', 200)
  end

  #GET /api/pedigree/query
  def query 
    current_patient_name = params[:name]
    match = " match (n)-[r:PADECE]->(e) //todas las personas que padecen una enfermedad
      where (n)-[:PADRE|MADRE*]-({nombre: '#{current_patient_name}'}) or
      n.nombre = '#{current_patient_name}'  //todas las personas de la familia del paciente
      return avg(r.edad_diagnostico) as promedio_edad_diagnostico //promedio de a que edad lo padecieron "
    result = @neo.execute_query match

    render json:result
  end

end