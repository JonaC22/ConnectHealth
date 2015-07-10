class StatisticsModel < BaseModel
  attr_accessor :query_cypher

  def set_query disease, query_type
    @query_cypher = "match (n)-[r:PADECE]->(e:ENFERMEDAD{nombre:'#{disease}'})"

    case query_type
    when "count"
      @query_cypher += "return count(r.edad_diagnostico) as Cantidad, r.edad_diagnostico as Edad"
    when "avg"
      @query_cypher += "return avg(r.edad_diagnostico) as Edad"
    end

  end

  def calc_query
    results = @neo.execute_query @query_cypher
    save_results
    results
  end

  def save_results
    get_mysql_connection
    #guardar resultados en mysql para historico
    close_mysql
  end
end