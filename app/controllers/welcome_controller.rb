class WelcomeController < ApplicationController

  @pacientes
  # GET /welcome
  def index
      @neo = Neography::Rest.new(ENV['NEO4J'])
      busqueda_paciente()
  end

  def busqueda_paciente

    unless params[:text_box_nombre_paciente].nil?
      query_busqueda_pacientes = "MATCH (n:PERSONA) WHERE n.nombre =~ '(?i).*"+ params[:text_box_nombre_paciente] +".*' RETURN n LIMIT 5"
    else
      query_busqueda_pacientes = "MATCH (n:PERSONA) RETURN n LIMIT 5"
    end
    @pacientes = @neo.execute_query(query_busqueda_pacientes)
  end

end
