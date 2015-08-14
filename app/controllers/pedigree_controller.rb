class PedigreeController < BaseController

  attr_accessor :pedigree

  skip_before_filter :verify_authenticity_token
  
  # GET /api/pedigree
  def index
    #generate

    id_current_patient = params[:id]
    unless id_current_patient == 'null'
      get_pedigree id_current_patient
    else
      results = []
      render json: results
    end

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

  def visualize(patients, id_current_patient)

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

  #GET /api/pedigree/get_fdr
  #Devuelve un par clave-valor, donde la clave es el id del pariente y el valor un array de id de enfermedades padecidas.
  #Se envia id del paciente
  def get_first_deg_relatives
    node = Neography::Node.load(params[:id], @neo)

    ret = []
    ret.push *node.both(:MADRE)
    ret.push *node.both(:PADRE)

    relatives = {}
    rel_ids = ret.map{|rel| rel.neo_id}
    rel_ids.each do |relative_id|
      n = Neography::Node.load(relative_id, @neo)
      diseases = []
      diseases.push *n.outgoing(:PADECE)
      diseases = diseases.map {|d| d.neo_id}
      relatives.store(relative_id, diseases)
    end

    render json:relatives
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
  #GET /api/pedigree/gailModelCalculate
  def calculate_gail_model
    # AgeIndicator: age ge 50 ind
    # 0=[20, 50)
    # 1=[50, 85)
    # MenarcheAge: age menarchy
    # 0=[14, 39] U 99 (unknown)
    # 1=[12, 14)
    # 2=[ 7, 12)
    # NumberOfBiopsy: # biopsy
    # 0=0 or (99 and ever had biopsy=99
    # 1=1 or (99 and ever had biopsy=1 y
    # 2=[ 2, 30]
    # FirstLiveBirthAge: age 1st live
    # 0=<20, 99 (unknown)
    # 1=[20, 25)
    # 2=[25, 30) U 0
    # 3=[30, 55]
    # FirstDegRelatives: 1st degree rel
    # 0=0, 99 (unknown)
    # 1=1
    # 2=[2, 31]

    #  RiskIndex           [1 Abs, 2 Avg]
    #, CurrentAge		    //[t1] edad actual ( tiene que ser mayor a 35)
    #, ProjectionAge	    //[t2]
    #, AgeIndicator	    //[i0]
    #, NumberOfBiopsy	    //[i2] cant de biopsias de mamas 1, 2(2 o mas)
    #, MenarcheAge		    //[i1] edad de primera menstruacion
    #, FirstLiveBirthAge   //[i3] 2 ()never) , 0 (<20),1(20-24), 2(25-29),3(>=30)
    #, EverHadBiopsy	    //[iever] 0 no, 1 yes, 99 unknown
    #, HyperPlasia		    //[ihyp] 0 no, 1 yes, 99 unknown
    #, FirstDegRelatives   //[i4] 0, 1 or 2(2 or more)
    #, RHyperPlasia	    //[rhyp] 0 no, 1 yes, 99 unknown
    #, Race			    //[race] 1-white 3-hispanic 6-unknown
    RiskCalculator.new
    current_age=params[:age].to_i
    projection_age=current_age+5
    menarche_age = BcptConvert.MenarcheAge(params[:menstAge].to_i)
    first_live_birth_age=BcptConvert.FirstLiveBirthAge(params[:first_birth_age].to_i)
    age_indicator=BcptConvert.CurrentAgeIndicator(current_age)
    ever_had_biopsy_bool=false
    ever_had_biopsy=ever_had_biopsy_bool ? 1 : 0
    number_of_biopsy = ever_had_biopsy_bool ? params[:numberBiopsy].to_i : 0
    race = 3 #Hispanic
    first_deg_relatives = BcptConvert.FirstDegRelatives(params[:relatives].to_i,race)
    ihyp=BcptConvert.hyperplasia(0,ever_had_biopsy_bool)
    rhyp=BcptConvert.r_hyperplasia(ihyp)
    # calculate_absolute_risk(current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, irace)
    abs_risk = RiskCalculator.new.calculate_absolute_risk(current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race)
    avg_risk = RiskCalculator.new.calculate_average_risk(current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race)
    abs_risk90 = RiskCalculator.new.calculate_absolute_risk(current_age, 90, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race)
    avg_risk90 = RiskCalculator.new.calculate_average_risk(current_age, 90, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race)
    # abs_risk = RiskCalculator.new.calculate_absolute_risk(38,43,0,0,2,BcptConvert.FirstLiveBirthAge(0),2,0,0,1.0,1)
    # avg_risk = RiskCalculator.new.calculate_average_risk(38,43,0,0,2,BcptConvert.FirstLiveBirthAge(0),2,0,0,1.0,1)
    # abs_risk90 = RiskCalculator.new.calculate_absolute_risk(38,90,0,0,2,BcptConvert.FirstLiveBirthAge(0),2,0,0,1.0,1)
    # avg_risk90 = RiskCalculator.new.calculate_average_risk(38,90,0,0,2,BcptConvert.FirstLiveBirthAge(0),2,0,0,1.0,1)
    result = {'absoluteRiskIn5Years' => abs_risk, 'averageRiskIn5Years' => avg_risk,'absoluteRiskAt90yo' => abs_risk90, 'averageRiskAt90yo' => avg_risk90}
    render json: result
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