class StatisticsModel < BaseModel
  attr_accessor :query

  def set_query(disease, query_type, degree, options)
    @query = "match (e:ENFERMEDAD{nombre:'#{disease}'})-[r:PADECE]-(n)"

    #con o sin enfermedad en parientes intermedios de la relacion
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

  def calc_query
    result = @neo.execute_query @query
    save_report result
    result
  end

  # GET /api/statistics/reports
  # devuelve listado de historico de reportes
  def get_reports
    mysql_connection
    # select sobre la tabla statistical_reports
    close_mysql
  end

  # devuelve el resultado de un reporte
  def show_report(_id)
    mysql_connection
    # select sobre la tabla statistical_reports con where sobre el campo id
    close_mysql
  end

  def save_report(_result)
    hash = { :statement => @query, :result => _result }
    StatisticalReport.create! hash
  end
end
