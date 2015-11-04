# == Schema Information
#
# Table name: statistical_reports
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  statement   :string(255)
#  description :string(255)
#  result      :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_statistical_reports_on_user_id  (user_id)
#

class StatisticalReport < ActiveRecord::Base
  belongs_to :user
  before_create :execute_statement

  def self.generate_query(params)
    disease = params[:disease]
    query_type = params[:query_type]
    degree = params[:degree]
    options = params[:options]

    @query = "match (e:ENFERMEDAD{nombre:'#{disease}'})-[r:PADECE]-(n)"

    # con o sin enfermedad en parientes intermedios de la relacion
    case options
    when 'without'
      case degree
      when 'fdr'
        @query += '-[:PADRE|MADRE]->(p)-->(e)'
      when 'sdr'
        @query += '-[:PADRE|MADRE]->(i)-[:PADRE|MADRE]->(p)-->(e)'
        @query += ' WHERE NOT (i)-->(e)'
      when 'tdr'
        @query += '-[:PADRE|MADRE]->(i)-[:PADRE|MADRE]->(i2)-[:PADRE|MADRE]->(p)-->(e)'
        @query += ' WHERE NOT ( (i)-->(e) OR (i2)-->(e) )'
      else
        @query += ''
      end
    when 'with'
      case degree
      when 'fdr'
        @query += '-[:PADRE|MADRE]->(p)-->(e)'
      when 'sdr'
        @query += '-[:PADRE|MADRE]->(i)-[:PADRE|MADRE]->(p)-->(e)'
        @query += ' WHERE (i)-->(e)'
      when 'tdr'
        @query += '-[:PADRE|MADRE]->(i)-[:PADRE|MADRE]->(i2)-[:PADRE|MADRE]->(p)-->(e)'
        @query += ' WHERE ( (i)-->(e) AND (i2)-->(e) )'
      else
        @query += ''
      end
    when 'both'
      case degree
      when 'fdr'
        @query += '-[:PADRE|MADRE]->(p)-->(e)'
      when 'sdr'
        @query += '-[:PADRE|MADRE*2]->(p)-->(e)'
      when 'tdr'
        @query += '-[:PADRE|MADRE*3]->(p)-->(e)'
      else
        @query += ''
      end
    end
    case query_type
    when 'count'
      @query += 'return count(r.edad_diagnostico) as Cantidad, r.edad_diagnostico as Edad'
    when 'avg'
      @query += 'return avg(r.edad_diagnostico) as Edad'
    end
  end

  def neo
    @neo ||= Neography::Rest.new
  end

  def execute_statement
    result = neo.execute_query statement
    self.result = result
  end
end
