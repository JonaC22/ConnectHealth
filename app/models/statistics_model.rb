
class StatisticsModel
  attr_accessor :query_cypher

  def set_query disease, query_type

    if query_type == "count"
      @query_cypher =
          "match (n)-[r:PADECE]->(e:ENFERMEDAD{nombre:'#{disease}'})
         return count(r.edad_diagnostico) as count, r.edad_diagnostico as age "
    end

    if query_type == "avg"
      @query_cypher =
          "match (n)-[r:PADECE]->(e:ENFERMEDAD{nombre:'#{disease}'})
         return avg(r.edad_diagnostico)"
    end

  end

  def calc_query neo
    results = neo.execute_query @query_cypher
    save_results
    return results
  end

  def save_results
    #guardar resultados en mysql para historico
  end
end