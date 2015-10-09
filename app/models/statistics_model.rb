class StatisticsModel < BaseModel
  attr_accessor :query, :result

  def set_query(disease, query_type)
    @query = "match (n)-[r:PADECE]->(e:ENFERMEDAD{nombre:'#{disease}'})"
=begin
    case options
      when 'fdr'
        @query += ' optional match (hermano)-[:MADRE]->()<-[:MADRE]-(n)-[:PADRE]->()<-[:PADRE]-(hermano)
                  where (n)-[:PADRE|:MADRE]->()-[:PADECE]->(e) OR
                  (hermano)-[:PADECE]->(e) OR
                  (n)<-[:PADRE|:MADRE]-()-[:PADECE]->(e)'
      when 'sdr'
        @query += ' optional match (n)-[:PADRE|:MADRE]->(padre), (hermano)-[:MADRE]->()<-[:MADRE]-(n)-[:PADRE]->()<-[:PADRE]-(hermano),
                  (tio)-[:MADRE]->()<-[:MADRE]-(padre)-[:PADRE]->()<-[:PADRE]-(tio),
                  (n)-[:PADRE|:MADRE]->()<-[:PADRE|:MADRE]-(mhermano)
                  where (n)-[:PADRE|:MADRE*2]->()-[:PADECE]->(e) OR
                  (n)<-[:PADRE|:MADRE*2]-()-[:PADECE]->(e) OR
                  (hermano)<-[:PADRE|:MADRE]-()-[:PADECE]->(e) OR
                  (tio)-[:PADECE]->(e) OR
                  ( (mhermano)-[:PADECE]->(e) AND NOT
                     (mhermano)-[:MADRE]->()<-[:MADRE]-(n)-[:PADRE]->()<-[:PADRE]-(mhermano))'
      else
        @query += ''
    end
=end
    case query_type
    when 'count'
      @query += 'return count(r.edad_diagnostico) as Cantidad, r.edad_diagnostico as Edad'
    when 'avg'
      @query += 'return avg(r.edad_diagnostico) as Edad'
    end
  end

  def calc_query
    @result = @neo.execute_query @query
    save_report @result
    @result
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
    mysql_connection
    # guardar un reporte en mysql para historico (guardar resultado y fecha de generacion)
    close_mysql
  end
end
