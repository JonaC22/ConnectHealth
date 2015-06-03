class WelcomeController < ApplicationController
  skip_before_action :verify_authenticity_token

  @pacientes

  # GET /welcome
  def index
      @neo = Neography::Rest.new(ENV['NEO4J'])
      busqueda_paciente()
  end

  def busqueda_paciente

    unless params[:text_box_nombre_paciente].nil?
      nombre = params[:text_box_nombre_paciente]
      query_busqueda_pacientes = "MATCH (n:PERSONA) WHERE n.nombre =~ '(?i).*"+ nombre +".*' RETURN n LIMIT 7"
    else
      query_busqueda_pacientes = "MATCH (n:PERSONA) RETURN n LIMIT 7"
    end
    @pacientes = @neo.execute_query(query_busqueda_pacientes)
  end

  def insert_paciente
    @neo = Neography::Rest.new(ENV['NEO4J'])
    nombre = params[:text_box_nombre]
    apellido = params[:text_box_apellido]
    edad = params[:text_box_edad]
    query = "CREATE (n:PERSONA {nombre:'"+ nombre +"', apellido:'"+ apellido +"', edad:'"+ edad +"'})"
    @neo.execute_query(query)
    redirect_to '/'
  end

  def delete_paciente
    @neo = Neography::Rest.new(ENV['NEO4J'])
    nombre = params[:text_box_nombre_a_borrar]
    query = "MATCH (n:PERSONA) WHERE n.nombre =~ '"+ nombre +"' DELETE n"
    @neo.execute_query(query)
    redirect_to '/'
  end

end
