class PedigreeController < BaseController

  attr_accessor :pedigree 

  skip_before_filter :verify_authenticity_token


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
    patients['data'].each do |data_array|
      data_array.each do |node|
        data = node['data']
        person = Person.new node['metadata']['id'], data['nombre'], data['apellido'], data['fecha_nacimiento'], data['sexo']
        @pedigree.add person
        if person.name == current_patient_name 
          @pedigree.set_current person
        end
      end
    end

    #Se extraen relaciones
    @pedigree.get_people.each {|person|
      node = Neography::Node.load(person.id, @neo)

      node.rels(:PADRE, :MADRE).outgoing.each { |relat|

        #person es el nodo en cuestion y persona_related la persona con la que se relaciona
        relations << Relation.new(relat.start_node.neo_id.to_i, relat.end_node.neo_id.to_i, relat.rel_type)
      }
      node.rels(:PADECE).outgoing.each { |rel|
        person.diseases.append(Enfermedad.new rel.edad_diagnostico,rel.end_node.nombre)
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

    personas = Hash.new
    @json['personas'].each { |persona|
      tags = ['MADRE', 'PADRE']
      error = validate_relations @json, persona, tags
      if error.err_number == 500
        return render json:error
      end
      node = @neo.create_node('edad' => persona['edad'], 'nombre' => persona['nombre'], 'apellido' => persona['apellido'],'sexo' => persona['sexo'])
      @neo.set_label(node, 'PERSONA')
      personas[persona['id']] = node
    }
    
    @json['relations'].each { |rel|
      @neo.create_relationship(rel['name'], personas[rel['from']], personas[rel['to']])
    }

    resultado= Resultado.new('Pedigree ingresado exitosamente',200)
    render json:resultado
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
    current_patient_name = params[:name]
    match = " match (n)-[r:PADECE]->(e) //todas las personas que padecen una enfermedad
      where (n)-[:PADRE|MADRE*]-({nombre: '#{current_patient_name}'}) or
      n.nombre = '#{current_patient_name}'  //todas las personas de la familia del paciente
      return avg(r.edad_diagnostico) as promedio_edad_diagnostico //promedio de a que edad lo padecieron "
    result = @neo.execute_query match

    render json:result
  end

  #GET metodo provisorio para ver la carga batch de medicos en mysql
  def get_medicos_mysql
    medicos = @mysql.query('SELECT * FROM medicos')
    result = Hash.new
    result['medicos']=medicos
    render json:result
  end

  #GET metodo provisorio para ver la arga batch de pacientes en mysql
  def get_pacientes_mysql
    pacientes = @mysql.query('SELECT * FROM pacientes')
    result = Hash.new
    result['pacientes']=pacientes
    render json:result
  end

  def generate
    pacientes = @mysql.query('SELECT * FROM pacientes Limit 1')
    nombres_f = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="f"').map { |n| n['Nombre']}
    nombres_m = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="m"').map { |n| n['Nombre']}
    apellidos = @mysql.query('SELECT Apellido FROM pacientes').map { |n| n['Apellido']}
    familias = Array.new
    pacientes.each { |paciente|
      result = Hash.new
      p = Person.create_from_mysql(paciente)
      if p.gender=='F' && rand(10)>rand(4..6)
        cancer_mama = Enfermedad.new rand(20..50), 'Cancer de mama'
        p.add_disease(cancer_mama)
      end
      padre = p.create_father(nombres_m.sample)
      madre = p.create_mother(nombres_f.sample,apellidos.sample)
      result['paciente']=p
      result['padre']=padre
      if  rand(10)>rand(4..6)
        cancer_mama = Enfermedad.new rand(20..50), 'Cancer de mama'
        madre.add_disease(cancer_mama)
      end
      result['madre']=madre
      result['abuelo_pat']=padre.create_father(nombres_m.sample)
      result['abuela_pat']=padre.create_mother(nombres_f.sample,apellidos.sample)
      result['abuelo_mat']=madre.create_father(nombres_m.sample)
      result['abuela_mat']=madre.create_mother(nombres_f.sample,apellidos.sample)
      if  rand(10)>rand(4..6)
        cancer_mama = Enfermedad.new rand(20..50), 'Cancer de mama'
        result['abuela_mat'].add_disease(cancer_mama)
      end
      familias.append(result){}

    }
    render json:familias
  end



end