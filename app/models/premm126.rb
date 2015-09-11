=begin

  Calculates mutation risk for MLH1, MSH2, MSH6 genes
  References:

  crc = Colon-Rectal Cancer
  ec = Endometrial Cancer
  p = proband
  fdr = first degree relative
  sdr = second degree relative
  ls = Lynch Syndrome
  ls related cancers = stomach, ovaries, urinary tract, small intestine, pancreas, bile ducts,
                        brain (glioblastoma multiforme), sebaceous glands

=end
class PREMM126

  attr_accessor :const_lp, :age_bounds

  @const_lp = {
      mlh1: [-5.8, 0.66, 1.65, 2.87, 1.37, 0.87, 1.21, 0.96, 0.14, -0.66, -0.02],
      msh2: [-5.7, 0.65, 1.52, 2.71, 1.94, 1.6, 1.19, 1.09, 0.34, -0.52, -0.21],
      msh6: [-5.7, 0.53, 0.73, 1.66, 1.99, 0.37, 0.20, 1.09, 0.55, -0.07, 0.09]
  }

  @age_bounds = {
      crc: {
          :p => {
              :mlh1 => {:one => {:min => 20, :max => 70}, :more => {:min => 20, :max => 80}},
              :msh2 => {:one => {:min => 20, :max => 74}, :more => {:min => 20, :max => 80}},
              :msh6 => {:one => {:min => 20, :max => 80}, :more => {:min => 20, :max => 80}}
          },
          :fdr => {
              :mlh1 => {:one => {:min => 20, :max => 63}, :more => {:min => 20, :max => 80}},
              :msh2 => {:one => {:min => 20, :max => 68}, :more => {:min => 20, :max => 80}},
              :msh6 => {:one => {:min => 20, :max => 75}, :more => {:min => 20, :max => 80}}
          },
          :sdr => {
              :mlh1 => {:one => {:min => 20, :max => 54}, :more => {:min => 20, :max => 63}},
              :msh2 => {:one => {:min => 20, :max => 56}, :more => {:min => 20, :max => 68}},
              :msh6 => {:one => {:min => 20, :max => 60}, :more => {:min => 20, :max => 75}}
          }
      },
      ec: {
          :p => {
              :mlh1 => {:one => {:min => 20, :max => 80}},
              :msh2 => {:one => {:min => 20, :max => 80}},
              :msh6 => {:one => {:min => 20, :max => 80}}
          },
          :fdr => {
              :mlh1 => {:one => {:min => 20, :max => 80}, :more => {:min => 20, :max => 80}},
              :msh2 => {:one => {:min => 20, :max => 80}, :more => {:min => 20, :max => 80}},
              :msh6 => {:one => {:min => 20, :max => 80}, :more => {:min => 20, :max => 80}}
          },
          :sdr => {
              :mlh1 => {:one => {:min => 20, :max => 80}, :more => {:min => 20, :max => 80}},
              :msh2 => {:one => {:min => 20, :max => 80}, :more => {:min => 20, :max => 80}},
              :msh6 => {:one => {:min => 20, :max => 80}, :more => {:min => 20, :max => 80}}
          }
      }
  }
  #Returns an array with the eight primary values for the formula
  def self.get_primary_values(patient)
    array = []
    7.times { |i|
        array.push get_primary_value(patient, i)
    }
    array.flatten
  end

  def self.get_secondary_values(patient, gen)
    values = get_primary_values(patient).dup
    values.push get_secondary_value(patient, values, gen, 8)
    values.push get_secondary_value(patient, values, gen, 9)
    values[5] = values[5][:V]
    values[6] = values[6][:V]
    values
  end

  #TODO implement methods in Person class
  def self.get_primary_value(patient, i)
    case i
      when 0 then
        get_proband_gender patient
      when 1 then
        get_proband_crc_presence patient
      when 2 then
        0 #get_proband_ec_presence patient
      when 3 then
        0 #get_proband_ls_presence patient
      when 4 then
        get_relatives_crc_presence patient
      when 5 then
        get_relatives_ec_presence patient
      when 6 then
        0 #get_relatives_ls_presence patient
      else
        0
    end
  end

  def self.get_secondary_value(patient, values, gen, i)
    case i
      when 8 then
        get_youngest_age_diagnosis patient, values, gen, :crc
      when 9 then
        get_youngest_age_diagnosis patient, values, gen, :ec
      else
        0
    end
  end

  #V8 and V9
  def self.get_youngest_age_diagnosis(patient, values, gen, disease)
    #hash = patient.get_youngest_age_diagnosis disease
    hash = {:p => 15, :fdr => 82, :sdr => nil}
    hash = validate_bounds(hash, values, gen, disease)
    hash.map {|h| h - 45}.reduce(:+)
  end

  #V7
  def self.get_relatives_ls_presence(patient)
    patient.get_relatives_ls_presence
  end

  #V6 output format {:A, :B, :C, :D}
  def self.get_relatives_ec_presence(patient)
    #patient.get_relatives_ec_presence
    a = 0
    b = 0
    c = 0
    d = 0

    b = 0 if a == 1
    d = 0 if c == 1

    v = a + 2*b + 0.5*c + d

    {:A => a, :B => b, :C => c, :D => d, :V => v}
  end

  #V5 output format {:A, :B, :C, :D}
  def self.get_relatives_crc_presence(patient)
    #patient.get_relatives_crc_presence
    a = 0
    b = 0
    c = 0
    d = 0

    b = 0 if a == 1
    d = 0 if c == 1

    v = a + 2*b + 0.5*c + d

    {:A => a, :B => b, :C => c, :D => d, :V => v}
  end

  #V4
  def self.get_proband_ls_presence(patient)
    patient.get_proband_ls_presence
  end

  #V3 only valid for women
  def self.get_proband_ec_presence(patient)
    #patient.get_proband_ec_presence
    if patient.gender != 'F'
      0
    else

    end
  end

  #V1 and V2 output format [V1, V2]
  def self.get_proband_crc_presence(patient)
    #patient.get_proband_crc_presence
    [1, 0]
  end

  #V0
  def self.get_proband_gender(patient)
    patient.gender == 'F' ? 0 : 1
  end

  #Returns intermediate values for gene risk probabilities
  def self.get_lp_values(patient, v1, v2, v3, v4, v5, v6, v7, v8, v9)
    {mlh1: get_lp(patient, :mlh1, v1, v2, v3, v4, v5, v6, v7, v8, v9),
     msh2: get_lp(patient, :msh2, v1, v2, v3, v4, v5, v6, v7, v8, v9),
     msh6: get_lp(patient, :msh6, v1, v2, v3, v4, v5, v6, v7, v8, v9)}
  end

  #Returns individual risk mutation for specified gen
  def self.get_lp(patient, gen, v1, v2, v3, v4, v5, v6, v7, v8, v9)
    c = @const_lp[gen]
    v = get_secondary_values patient, gen
    c[0] + c[1]*v[0] + c[2]*v1 + c[3]*v2 + c[4]*v3 + c[5]*v4 +
        c[6]*v5 + c[7]*v6 + c[8]*v7 + c[9]*v8 / 10 + c[10]*v9 / 10
  end

  #Returns a hash with each gene mutation risk
  def self.get_mutation_probabilities(patient, v1, v2, v3, v4, v5, v6, v7, v8, v9)
    lp = get_lp_values patient, v1, v2, v3, v4, v5, v6, v7, v8, v9
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

  def self.calc_risk(patient, v1, v2, v3, v4, v5, v6, v7, v8, v9)
    get_mutation_probabilities(patient, v1, v2, v3, v4, v5, v6, v7, v8, v9).map { |_, v| v }.reduce(:+)
  end

  def self.get_no_mutation_probability(patient, v1, v2, v3, v4, v5, v6, v7, v8, v9)
    1 - calc_risk(patient, v1, v2, v3, v4, v5, v6, v7, v8, v9)
  end

  #Set min or max age if the value is out of bound
  def self.validate_bounds(ages, values, gen, disease)

    ages.map { |k, v|
      if v.nil? || !has_disease(k, values, disease)
        45
      else
        diag = map_diagnosis(k, values, disease)
        age = [v, @age_bounds[disease][k][gen][diag][:min]].max
        [age, @age_bounds[disease][k][gen][diag][:max]].min
      end
    }
  end

  #Map the count of diagnosis
  def self.map_diagnosis person, values, disease
    case person
      when :p then
        case disease
          when :crc then
            values[1] == 1 ? :one : :more
          when :ec then
            :one
          else
            :one
        end
      when :fdr then
        case disease
          when :crc then
            values[5][:A] == 1 ? :one : :more
          when :ec then
            values[6][:A] == 1 ? :one : :more
          else
            :one
        end
      when :sdr then
        case disease
          when :crc then
            values[5][:C] == 1 ? :one : :more
          when :ec then
            values[6][:C] == 1 ? :one : :more
          else
            :one
        end
      else
        :one
    end
  end

  #If values are equal, both are 0 (absent)
  def self.has_disease(person, values, disease)
    case person
      when :p then
        case disease
          when :crc then
            values[1] != values[2]
          when :ec then
            values[3] == 1
          else
            false
        end
      when :fdr then
        case disease
          when :crc then
            values[5][:A] != values[5][:B]
          when :ec then
            values[6][:A] != values[6][:B]
          else
            false
        end
      when :sdr then
        case disease
          when :crc then
            values[5][:C] != values[5][:D]
          when :ec then
            values[6][:C] != values[6][:D]
          else
            false
        end
      else
        false
    end
  end

end