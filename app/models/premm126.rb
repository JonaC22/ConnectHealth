class PREMM126

  attr_accessor :const_lp

  @const_lp = {
      mlh1: [-5.8, 0.66, 1.65, 2.87, 1.37, 0.87, 1.21, 0.96, 0.14, -0.66, -0.02],
      msh2: [-5.7, 0.65, 1.52, 2.71, 1.94, 1.6, 1.19, 1.09, 0.34, -0.52, -0.21],
      msh6: [-5.7, 0.53, 0.73, 1.66, 1.99, 0.37, 0.20, 1.09, 0.55, -0.07, 0.09]
  }

  #Returns an array with the nine primary values for the formula
  def self.get_primary_values(patient)
    array = []
    10.times { |i|
      array.push get_value(patient, i)
    }
    array.flatten
  end

  #TODO implement methods in Person class
  def self.get_value(patient, i)
    case i
      when 0 then get_proband_gender patient
      when 1..2 then get_proband_crc_presence patient
      when 3 then get_proband_ec_presence patient
      when 4 then get_proband_ls_presence patient
      when 5 then get_relatives_crc_presence patient
      when 6 then get_relatives_ec_presence patient
      when 7 then get_relatives_ls_presence patient
      when 8 then get_youngest_age_crc_diagnosis patient
      when 9 then get_youngest_age_ec_diagnosis patient
      else 0
    end
  end

  def self.get_youngest_age_ec_diagnosis(patient)
    patient.get_youngest_age_ec_diagnosis
  end

  def self.get_youngest_age_crc_diagnosis(patient)
    patient.get_youngest_age_crc_diagnosis
  end

  def self.get_relatives_ls_presence(patient)
    patient.get_relatives_ls_presence
  end

  def self.get_relatives_ec_presence(patient)
    patient.get_relatives_ec_presence
  end

  def self.get_relatives_crc_presence(patient)
    patient.get_relatives_crc_presence
  end

  def self.get_proband_ls_presence(patient)
    patient.get_proband_ls_presence
  end

  def self.get_proband_ec_presence(patient)
    patient.get_proband_ec_presence
  end

  def self.get_proband_crc_presence(patient)
    patient.get_proband_crc_presence
  end

  def self.get_proband_gender(patient)
    patient.gender == 'F' ? 0 : 1
  end

  #Returns intermediate values for gene risk probabilities
  def self.get_lp_values(patient)
    {mlh1: get_lp(patient, :mlh1), msh2: get_lp(patient, :msh2), msh6: get_lp(patient, :msh6)}
  end

  #Returns individual risk mutation for specified gen
  def self.get_lp(patient, gen)
    c = @const_lp[gen]
    v = get_primary_values patient
    c[0] + c[1]*v[0] + c[2]*v[1] + c[3]*v[2] + c[4]*v[3] + c[5]*v[4] +
        c[6]*v[5] + c[7]*v[6] + c[8]*v[7] + c[9]*v[8] / 10 + c[10]*v[9] / 10
  end

  #Returns a hash with all
  def self.get_mutation_probabilities(patient)
    lp = get_lp_values patient
    exp_mlh1 = Math.exp(lp[:mlh1])
    exp_msh2 = Math.exp(lp[:msh2])
    exp_msh6 = Math.exp(lp[:msh6])
    denominator = 1 + exp_mlh1 + exp_msh2 + exp_msh6
    {
        mlh1: exp_mlh1 / denominator,
        msh2: exp_msh2 / denominator,
        msh6: exp_msh6 / denominator
    }
  end

  def self.calc_risk(patient)
    get_mutation_probabilities(patient).map { |_, v| v }.reduce(:+)
  end

  def self.get_no_mutation_probability(patient)
    1 - calc_risk(patient)
  end
end