class PedigreeController < BaseController

  attr_accessor :pedigree

  skip_before_filter :verify_authenticity_token
  
  # GET /api/pedigree
  def index
    #generate
    id_current_patient = params[:id]
    get_pedigree id_current_patient
  end

  def get_pedigree id_current_patient
    query_busqueda_pacientes =
        " match (n:PERSONA)-[r:PADRE|MADRE*]-(n2:PERSONA)
        where id(n) = #{id_current_patient}
        return n2 as nodo
        UNION
        match(n:PERSONA)
        where id(n) = #{id_current_patient}
        return n as nodo"
    patients = @neo.execute_query query_busqueda_pacientes
    visualize patients, id_current_patient
  end

  def visualize patients, id_current_patient
    persons = []
    relations = []
    @pedigree = Pedigree.new

    #Se extraen personas y relaciones
    patients['data'].each do |data_array|
      data_array.each do |node|
        data = node['data']
        person = Person.new node['metadata']['id'], data['nombre'], data['apellido'], data['fecha_nacimiento'], data['sexo']
        @pedigree.add person
        if person.id.to_s == id_current_patient
          @pedigree.set_current person
        end
      end
    end

    #Se extraen relaciones
    @pedigree.get_people.each { |person|
      node = Neography::Node.load(person.id, @neo)

      node.rels(:PADRE, :MADRE).outgoing.each { |relat|
        YAML::dump relat
        #person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations << Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.rel_type)
      }
      node.rels(:PADECE).outgoing.each { |rel|
        person.diseases.append(Disease.new rel.edad_diagnostico, rel.end_node.nombre)
      }
    }

    @pedigree.add_elements relations

    #puts YAML::dump(pedigree)

    render json: @pedigree.to_json
  end

  before_filter only: :create do
    @json = JSON.parse(request.body.read)
    unless @json.has_key?('personas') && @json.has_key?('relations')
      render nothing: true, status: :bad_request
    end
  end

  #POST /api/pedigree
  def create

    personas = Hash.new
    @json['personas'].each { |persona|
      tags = ['MADRE', 'PADRE']
      error = validate_relations @json, persona, tags
      if error.err_number == 500
        return render json: error
      end
      node = @neo.create_node('edad' => persona['edad'], 'nombre' => persona['nombre'], 'apellido' => persona['apellido'], 'sexo' => persona['sexo'])
      @neo.set_label(node, 'PERSONA')
      personas[persona['id']] = node
    }

    @json['relations'].each { |rel|
      @neo.create_relationship(rel['name'], personas[rel['from']], personas[rel['to']])
    }

    resultado= Resultado.new('Pedigree ingresado exitosamente', 200)
    render json: resultado
  end

  def validate_relations(json, persona, tags)
    tags.each do |tag|
      count = json['relations'].count { |rel| rel['from'] == persona['id'] && rel['name'] == tag }
      if count > 1
        return Resultado.new("Relacion duplicada: #{tag}", 500)
      end
    end
    Resultado.new('OK', 200)
  end

  #GET /api/pedigree/query
  def query
    id_current_patient = params[:id]
    type = params[:type] || nil

    #query genérica que devuelve todos los familiares que padecen una enfermedad
    match = " match (n)-[r:PADECE]->(e)
              where ((n)-[:PADRE|MADRE*]-(n2) and id(n2) = #{id_current_patient}) or
              id(n) = #{id_current_patient} "
    case type
      when 'integer'
        execute_and_render match << " return count(r) as cantidad_casos "
      when 'float'
        execute_and_render match << " return avg(r.edad_diagnostico) as promedio_edad_diagnostico "
      when 'table'
        execute_and_render match << " return r.edad_diagnostico as edad_diagnostico "
      when 'pedigree' #Obtiene el pedigree recortado
        match = " match ca = (n:PERSONA)-[:PADRE|MADRE*]-(n2), (n2:PERSONA)-[:PADECE]->(e)
                  where id(n) = #{id_current_patient}
                  with nodes(ca) as nodos
                  unwind nodos as nodo
                  return nodo "
        patients = @neo.execute_query match

        visualize patients, id_current_patient
      else
        result = {"status" => "ERROR", "results" => "Formato de respuesta no especificado"}
        render json: result
    end
  end

  def execute_and_render match
    result = @neo.execute_query match
    render json: result
  end

  #GET metodo provisorio para ver la carga batch de medicos en mysql
  def get_medicos_mysql
    get_mysql_connection
    medicos = @mysql.query('SELECT * FROM medicos')
    result = Hash.new
    result['medicos']=medicos
    close_mysql
    render json: result
  end

  #GET metodo provisorio para ver la carga batch de pacientes en mysql
  def get_pacientes_mysql
    get_mysql_connection
    pacientes = @mysql.query('SELECT * FROM pacientes')
    result = Hash.new
    result['pacientes']=pacientes
    close_mysql
    render json: result
  end

end