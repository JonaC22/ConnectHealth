#
#   Calculates mutation risk for MLH1, MSH2, MSH6 genes
#   References:
#
#   crc = Colon-Rectal Cancer
#   ec = Endometrial Cancer
#   p = proband
#   fdr = first degree relative
#   sdr = second degree relative
#   ls = Lynch Syndrome
#   ls related cancers = stomach, ovaries, urinary tract, small intestine, pancreas, bile ducts,
#                         brain (glioblastoma multiforme), sebaceous glands
#
class PREMM126
  attr_accessor :const_lp, :age_bounds, :ls_related_cancers

  @ls_related_cancers = [
      'cancer de estomago', 'cancer de ovario', 'cancer de tracto urinario',
      'cancer de intestino delgado', 'cancer de pancreas', 'cancer de vía bilial',
      'cancer de cerebro', 'cancer de glandulas sebaceas']

  @const_lp = {
    mlh1: [-5.8, 0.66, 1.65, 2.87, 1.37, 0.87, 1.21, 0.96, 0.14, -0.66, -0.02],
    msh2: [-5.7, 0.65, 1.52, 2.71, 1.94, 1.6, 1.19, 1.09, 0.34, -0.52, -0.21],
    msh6: [-5.7, 0.53, 0.73, 1.66, 1.99, 0.37, 0.20, 1.09, 0.55, -0.07, 0.09]
  }

  @age_bounds = {
    crc: {
      p: {
        mlh1: { one: { min: 20, max: 70 }, more: { min: 20, max: 80 } },
        msh2: { one: { min: 20, max: 74 }, more: { min: 20, max: 80 } },
        msh6: { one: { min: 20, max: 80 }, more: { min: 20, max: 80 } }
      },
      fdr: {
        mlh1: { one: { min: 20, max: 63 }, more: { min: 20, max: 80 } },
        msh2: { one: { min: 20, max: 68 }, more: { min: 20, max: 80 } },
        msh6: { one: { min: 20, max: 75 }, more: { min: 20, max: 80 } }
      },
      sdr: {
        mlh1: { one: { min: 20, max: 54 }, more: { min: 20, max: 63 } },
        msh2: { one: { min: 20, max: 56 }, more: { min: 20, max: 68 } },
        msh6: { one: { min: 20, max: 60 }, more: { min: 20, max: 75 } }
      }
    },
    ec: {
      p: {
        mlh1: { one: { min: 20, max: 80 } },
        msh2: { one: { min: 20, max: 80 } },
        msh6: { one: { min: 20, max: 80 } }
      },
      fdr: {
        mlh1: { one: { min: 20, max: 80 }, more: { min: 20, max: 80 } },
        msh2: { one: { min: 20, max: 80 }, more: { min: 20, max: 80 } },
        msh6: { one: { min: 20, max: 80 }, more: { min: 20, max: 80 } }
      },
      sdr: {
        mlh1: { one: { min: 20, max: 80 }, more: { min: 20, max: 80 } },
        msh2: { one: { min: 20, max: 80 }, more: { min: 20, max: 80 } },
        msh6: { one: { min: 20, max: 80 }, more: { min: 20, max: 80 } }
      }
    }
  }
  # Returns an array with the eight primary values for the formula
  def self.primary_values(patient)
    array = []
    7.times do |i|
      array.push primary_value(patient, i)
    end
    array.flatten
  end

  def self.secondary_values(patient, gen)
    values = primary_values(patient).dup
    values.push secondary_value(patient, values, gen, 8)
    values.push secondary_value(patient, values, gen, 9)
    values[5] = values[5][:V]
    values[6] = values[6][:V]
    values
  end

  # TODO: implement methods in Person class
  def self.primary_value(patient, i)
    case i
    when 0 then
      proband_gender patient
    when 1 then
      proband_crc_presence patient
    when 2 then
      proband_ec_presence patient
    when 3 then
      proband_ls_presence patient
    when 4 then
      relatives_crc_presence patient
    when 5 then
      relatives_ec_presence patient
    when 6 then
      0 # relatives_ls_presence patient
    else
      0
    end
  end

  def self.secondary_value(patient, values, gen, i)
    case i
    when 8 then
      youngest_age_diagnosis patient, values, gen, :crc
    when 9 then
      youngest_age_diagnosis patient, values, gen, :ec
    else
      0
    end
  end

  # V8 and V9
  def self.youngest_age_diagnosis(patient, values, gen, disease)
    # hash = patient.youngest_age_diagnosis disease
    hash = { p: 15, fdr: 82, sdr: nil }
    hash = validate_bounds(hash, values, gen, disease)
    hash.map { |h| h - 45 }.reduce(:+)
  end

  # V7
  def self.relatives_ls_presence(patient)
    patient.relatives_ls_presence
  end

  # V6 output format {:A, :B, :C, :D}
  def self.relatives_ec_presence(patient)
    # patient.relatives_ec_presence
    a = 0
    b = 0
    c = 0
    d = 0

    b = 0 if a == 1
    d = 0 if c == 1

    v = a + 2 * b + 0.5 * c + d

    { A: a, B: b, C: c, D: d, V: v }
  end

  # V5 output format {:A, :B, :C, :D}
  def self.relatives_crc_presence(patient)
    # patient.relatives_crc_presence
    a = 0
    b = 0
    c = 0
    d = 0

    b = 0 if a == 1
    d = 0 if c == 1

    v = a + 2 * b + 0.5 * c + d

    { A: a, B: b, C: c, D: d, V: v }
  end

  # V4
  def self.proband_ls_presence(patient)
    enf_padecidas = patient.diseases_diagnoses(nil).map{|diag| diag.end_node.nombre}
    intersec = enf_padecidas & @ls_related_cancers
    if intersec.length > 0
      1
    else
      0
    end
  end

  # V3 only valid for women
  def self.proband_ec_presence(patient)
    if patient.diseases_diagnoses('cancer de endometrio').length > 0 && patient.gender == 'F'
      1
    else
      0
    end
  end

  # V1 and V2 output format [V1, V2]
  def self.proband_crc_presence(patient)
    case patient.diseases_diagnoses('cancer colon rectal').length
      when 0 then [0,0]
      when 1 then [1,0]
      else [0,1]
    end
  end

  # V0
  def self.proband_gender(patient)
    patient.gender == 'F' ? 0 : 1
  end

  # Returns intermediate values for gene risk probabilities
  def self.lp_values(params)
    {
      mlh1: lp(params.merge(gen: :mlh1)),
      msh2: lp(params.merge(gen: :msh2)),
      msh6: lp(params.merge(gen: :msh6))
    }
  end

  # Returns individual risk mutation for specified gen
  def self.lp(params)
    c = @const_lp[params[:gen]]
    v = secondary_values params[:patient], params[:gen]
    # puts ("v0: #{v[0]} v1: #{v[1]} v2: #{v[2]} v3: #{v[3]} v4: #{v[4]} v5: #{v[5]} v6: #{v[6]} v7: #{v[7]} v8: #{v[8]} v9: #{v[9]}")
    c[0] + c[1] * v[0] + c[2] * v[1] + c[3] * v[2] + c[4] * v[3] + c[5] * params[:v4] +
      c[6] * params[:v5] + c[7] * params[:v6] + c[8] * params[:v7] + c[9] * params[:v8] / 10 + c[10] * params[:v9] / 10
  end

  # Returns a hash with each gene mutation risk
  def self.mutation_probabilities(params)
    lp = lp_values params
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

  def self.calc_risk(params)
    mutation_probabilities(params).map { |_, v| v }.reduce(:+)
  end

  def self.no_mutation_probability(params)
    1 - calc_risk(params)
  end

  # Set min or max age if the value is out of bound
  def self.validate_bounds(ages, values, gen, disease)
    ages.map do |k, v|
      if v.nil? || !has_disease(k, values, disease)
        45
      else
        diag = map_diagnosis(k, values, disease)
        age = [v, @age_bounds[disease][k][gen][diag][:min]].max
        [age, @age_bounds[disease][k][gen][diag][:max]].min
      end
    end
  end

  # Map the count of diagnosis
  def self.map_diagnosis(person, values, disease)
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

  # If values are equal, both are 0 (absent)
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
