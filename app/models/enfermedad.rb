class Enfermedad

  attr_accessor :nombre,:edad_diagnostico

  def initialize(edad, nombre)
    @edad_diagnostico=edad
    @nombre=nombre
  end

  def get_node
    unless @node.nil?
      return @node
    end
    neo = Neography::Rest.new
    begin
      @node = Neography::Node.find('enfermedad_index', 'nombre', @nombre)
      return @node
    rescue Neography::NotFoundException => err
      @node = neo.create_node('nombre' => @nombre)
      neo.set_label(@node, 'ENFERMEDAD')
      neo.add_node_to_index('enfermedad_index', 'nombre', @nombre,@node)
      return @node
    end
  end

end