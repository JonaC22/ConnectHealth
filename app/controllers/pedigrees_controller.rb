class PedigreesController < BaseController
  # GET /api/pedigree
  def index
    results = Pedigree.all.select(:id)
    render json: results
  end

  def show
    pedigree pedigree_find_params
  end

  def pedigree(params)
    return unless params[:id]
    pedigree = Pedigree.find_by_id! params[:id]
    visualize pedigree, params[:current_patient]
  end

  def visualize(pedigree, id_current_patient = nil)
    relations = []
    # Se extraen relaciones
    pedigree.patients.each do |person|
      node = person.node
      node.rels(:PADRE, :MADRE).outgoing.each do |relat|
        # person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations << Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.rel_type)
      end
    end

    pedigree.relations = relations
    pedigree.current_patient = id_current_patient || Patient.where(pedigree: pedigree.id, patient_type: 'patient').first
    render json: pedigree
  end

  def create
    @json = JSON.parse(request.body.read)
    fail ImposibleRelationException, 'Missing personas or relations' unless @json.key?('personas') && @json.key?('relations')
    @pedigree = Pedigree.new
    @json['personas'].each do |persona|
      tags = %w(MADRE PADRE)
      validate_relations @json, persona, tags
      Patient.create! name: persona['nombre'], lastname: persona['apellido'], document_number: persona['dni'], document_type: persona['tipo'], pedigree: @pedigree, birth_age: persona['fecha_nacimiento'], type: 'relative'
      personas[persona['id']] = node
    end

    @json['relations'].each do |rel|
      @neo.create_relationship(rel['name'], personas[rel['from']], personas[rel['to']])
    end

    render json: (visualize @pedigree)
  end

  def update
    @json = JSON.parse(request.body.read)
    fail ImposibleRelationException, 'Missing relations' unless @json.key?('relations')
    params = pedigree_find_params
    @pedigree = Pedigree.find_by!(params)
    relations = []
    @pedigree.patients.each do |patient|
      patient.node.rels(:PADRE, :MADRE).outgoing.each do |relat|
        relations << Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.rel_type)
      end
    end
    @pedigree.patients.each(&:delete_all_relationships)
    begin
      @json['relations'].each do |rel|
        pat = Patient.find_by!(pedigree: @pedigree, neo_id: rel['from'])
        relative = Patient.find_by!(pedigree: @pedigree, neo_id: rel['to'])
        pat.create_relationship(rel['name'].to_sym, relative)
      end
    rescue StandardError
      @pedigree.patients.each(&:delete_all_relationships)
      relations.each do |rel|
        pat = Patient.find_by!(pedigree: @pedigree, neo_id: rel.from)
        relative = Patient.find_by!(pedigree: @pedigree, neo_id: rel.to)
        pat.create_relationship(rel.name.to_sym, relative)
      end
      raise
    end

    visualize @pedigree
  end

  # GET /api/pedigree/query
  def query
    id_current_patient = params[:id]
    type = params[:type] || nil

    # query generica que devuelve todos los familiares que padecen una enfermedad
    query = " match (n)-[r:PADECE]->(e)
    where ((n)-[:PADRE|MADRE*]-(n2) and id(n2) = #{id_current_patient}) or
    id(n) = #{id_current_patient} "
    case type
    when 'integer'
      execute_and_render query << ' return count(r) as cantidad_casos '
    when 'float'
      execute_and_render query << ' return avg(r.edad_diagnostico) as promedio_edad_diagnostico '
    when 'table'
      execute_and_render query << ' return r.edad_diagnostico as edad_diagnostico '
    when 'pedigree' # Obtiene el pedigree recortado
      query = " match ca = (n:PERSONA)-[:PADRE|MADRE*]-(n2), (n2:PERSONA)-[:PADECE]->(e)
      where id(n) = #{id_current_patient}
      with nodes(ca) as nodos
      unwind nodos as nodo
      return nodo "
      patients = @neo.execute_query query

      visualize patients, id_current_patient
    else
      result = { 'status' => 'ERROR', 'results' => 'Formato de respuesta no especificado' }
      render json: result
    end
  end

  def execute_and_render(match)
    result = @neo.execute_query match
    render json: result
  end

  private

  def pedigree_find_params
    {
      id: params[:id]
    }
  end

  def validate_relations(json, persona, tags)
    tags.each do |tag|
      count = json['relations'].count { |rel| rel['from'] == persona && rel['name'] == tag }
      fail ImposibleRelationException, "Relacion duplicada: #{tag}" if count > 1
    end
  end
end
