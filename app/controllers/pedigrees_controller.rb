class PedigreeController < BaseController
  attr_accessor :pedigree
  # GET /api/pedigree
  def index
    id_current_patient = params[:id]
    get_pedigree id_current_patient
  end

  def show
    pedigree pedigree_find_params
  end

  def pedigree(params)
    return unless id_current_patient
    pedigree = pedigree.find_by_id params[:id]
    visualize pedigree, params[:current_patient]
  end

  def visualize(pedigree, id_current_patient)
    relations = []
    # Se extraen relaciones
    pedigree.patients.each do |patient|
      node = Neography::Node.load(patient.id, @neo)

      node.rels(:PADRE, :MADRE).outgoing.each do |relat|
        YAML.dump relat
        # person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations << Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.rel_type)
      end
      node.rels(:PADECE).outgoing.each do |rel|
        patient.diseases << Disease.new(rel.edad_diagnostico, rel.end_node.nombre)
      end
    end
    @pedigree.relations = relations
    @pedigree.current_patient = id_current_patient
    render json: pedigree
  end

  before_filter only: :create do
    @json = JSON.parse(request.body.read)
    unless @json.key?('personas') && @json.key?('relations')
      render nothing: true, status: :bad_request
    end
  end

  def create
    @pedigree = Pedigree.new
    @json['personas'].each do |persona|
      Patient.create! name: persona['nombre'], lastname: persona['apellido'], document_number: persona['dni'], document_type: persona['tipo'], pedigree: @pedigree
      tags = %w('MADRE', 'PADRE')
      error = validate_relations @json, persona, tags
      return render json: error if error.err_number == 500
      node = @neo.create_node('edad' => persona['edad'], 'nombre' => persona['nombre'], 'apellido' => persona['apellido'], 'sexo' => persona['sexo'])
      @neo.set_label(node, 'PERSONA')
      personas[persona['id']] = node
    end

    @json['relations'].each do |rel|
      @neo.create_relationship(rel['name'], personas[rel['from']], personas[rel['to']])
    end

    resultado = Resultado.new('Pedigree ingresado exitosamente', 200)
    render json: resultado
  end

  # GET /api/pedigree/query
  def query
    id_current_patient = params[:id]
    type = params[:type] || nil

    # query genérica que devuelve todos los familiares que padecen una enfermedad
    match = " match (n)-[r:PADECE]->(e)
              where ((n)-[:PADRE|MADRE*]-(n2) and id(n2) = #{id_current_patient}) or
              id(n) = #{id_current_patient} "
    case type
    when 'integer'
      execute_and_render match << 'return count(r) as cantidad_casos'
    when 'float'
      execute_and_render match << 'return avg(r.edad_diagnostico) as promedio_edad_diagnostico'
    when 'table'
      execute_and_render match << 'return r.edad_diagnostico as edad_diagnostico'
    when 'pedigree' # Obtiene el pedigree recortado
      match = " match ca = (n:PERSONA)-[:PADRE|MADRE*]-(n2), (n2:PERSONA)-[:PADECE]->(e)
                where id(n) = #{id_current_patient}
                with nodes(ca) as nodos
                unwind nodos as nodo
                return nodo "
      patients = @neo.execute_query match

      visualize patients, id_current_patient
    else
      result = { status: 'ERROR', results: 'Formato de respuesta no especificado' }
      render json: result
    end
  end

  def execute_and_render(match)
    result = @neo.execute_query match
    render json: result
  end

  private

  def pedigree_find_params
    { id: params[:id],
      current_patient: params[:current_patient]
    }
  end

  def validate_relations(json, persona, tags)
    tags.each do |tag|
      count = json['relations'].count { |rel| rel['from'] == persona['id'] && rel['name'] == tag }
      return Resultado.new("Relacion duplicada: #{tag}", 500) if count > 1
    end
    Resultado.new('OK', 200)
  end
end