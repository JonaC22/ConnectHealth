class ModelCalculator
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :model, :calculations

  def premm126(params)
    params = premm_params(params)
    params[:patient] = Patient.find_by_neo_id!(params[:patient])
    validate_premm126(params[:patient])
    PREMM126.calc_risk(params)
  end

  def gail(params)
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
    # , CurrentAge       //[t1] edad actual ( tiene que ser mayor a 35)
    # , ProjectionAge      //[t2]
    # , AgeIndicator     //[i0]
    # , NumberOfBiopsy     //[i2] cant de biopsias de mamas 1, 2(2 o mas)
    # , MenarcheAge        //[i1] edad de primera menstruacion
    # , FirstLiveBirthAge   //[i3] 2 ()never) , 0 (<20),1(20-24), 2(25-29),3(>=30)
    # , EverHadBiopsy      //[iever] 0 no, 1 yes, 99 unknown
    # , HyperPlasia        //[ihyp] 0 no, 1 yes, 99 unknown
    # , FirstDegRelatives   //[i4] 0, 1 or 2(2 or more)
    # , RHyperPlasia     //[rhyp] 0 no, 1 yes, 99 unknown
    # , Race         //[race] 1-white 3-hispanic 6-unknown
    calculator = RiskCalculator.new
    params = gail_params(params) # evita parametros de mas y valida que esten los necesarios
    patient = Patient.find_by!(id: params[:patient_id])
    validate_gail(patient)
    current_age = patient.age

    fdr = patient.first_deg_relatives

    affected_relatives = fdr.count do |_key, value|
      !value.nil? && value.include?('Cancer de Mama')
    end

    projection_age = current_age + 5
    menarche_age = BcptConvert.MenarcheAge(params[:menarcheAge])
    first_live_birth_age = BcptConvert.FirstLiveBirthAge(patient.first_live_birth_age)
    age_indicator = BcptConvert.CurrentAgeIndicator(current_age)
    ever_had_biopsy = params[:numberBiopsy] > 0
    number_of_biopsy = ever_had_biopsy ? BcptConvert.number_of_biopsy(params[:numberBiopsy], true) : 0
    race = 1 # White or Unknown
    first_deg_relatives = BcptConvert.FirstDegRelatives(affected_relatives, race)
    ihyp = BcptConvert.hyperplasia(0, ever_had_biopsy)
    rhyp = BcptConvert.r_hyperplasia(ihyp)

    # calculate_absolute_risk(current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, irace)
    # logger.info 'Gail Params: current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race '
    # logger.info [current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race].to_s
    abs_risk = calculator.calculate_absolute_risk(current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race)
    avg_risk = calculator.calculate_average_risk(current_age, projection_age, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race)
    abs_risk90 = calculator.calculate_absolute_risk(current_age, 90, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race)
    avg_risk90 = calculator.calculate_average_risk(current_age, 90, age_indicator, number_of_biopsy, menarche_age, first_live_birth_age, first_deg_relatives, ever_had_biopsy, ihyp, rhyp, race)
    # abs_risk = RiskCalculator.new.calculate_absolute_risk(66,71,1,0,2,BcptConvert.FirstLiveBirthAge(17),2,0,99,1.0,1)
    # avg_risk = RiskCalculator.new.calculate_average_risk(38,43,0,0,2,BcptConvert.FirstLiveBirthAge(0),2,0,0,1.0,1)
    # abs_risk90 = RiskCalculator.new.calculate_absolute_risk(66,90,1,0,2,BcptConvert.FirstLiveBirthAge(17),2,0,99,1.0,1)
    # avg_risk90 = RiskCalculator.new.calculate_average_risk(38,90,0,0,2,BcptConvert.FirstLiveBirthAge(0),2,0,0,1.0,1)
    self.model = 'gail'
    self.calculations = { absoluteRiskIn5Years: abs_risk, averageRiskIn5Years: avg_risk, absoluteRiskAt90yo: abs_risk90, averageRiskAt90yo: avg_risk90 }
    self
  end

  private

  def validate_gail(patient)
    fail IncalculableModelException, 'Algoritmo no aplicable a pacientes no vivos' unless patient.alive?
    fail IncalculableModelException, 'Algoritmo no aplicable a pacientes de sexo masculino' if patient.gender == 'M'
    fail IncalculableModelException, 'Algoritmo no aplicable a pacientes que ya padezcan la enfermedad de Cancer de mama' if patient.diseases.include? 'Cancer de Mama'
    fail IncalculableModelException, 'Algoritmo no aplicable a pacientes mayores a 90 años' if patient.age > 90
    fail IncalculableModelException, 'Algoritmo no aplicable a pacientes menores a 35 años' if patient.age < 35
  end

  def validate_premm126(patient)
    fail IncalculableModelException, 'Algoritmo no aplicable a pacientes no vivos' unless patient.alive?
  end

  def gail_params(params)
    {
      patient_id: params.require(:patient_id),
      menarcheAge: params.require(:menarcheAge).to_i,
      numberBiopsy: params.require(:numberBiopsy).to_i
    }
  end

  def premm_params(params)
    {
      patient: params.require(:patient_id),
      v1: params.require(:v1).to_i,
      v2: params.require(:v2).to_i,
      v3: params.require(:v3).to_i,
      v4: params.require(:v4).to_i,
      v5: params.require(:v5).to_i,
      v6: params.require(:v6).to_i,
      v7: params.require(:v7).to_i,
      v8: params.require(:v8).to_i,
      v9: params.require(:v9).to_i
    }
  end
end
