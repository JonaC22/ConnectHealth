class Disease
  attr_accessor :nombre, :edad_diagnostico

  def initialize(edad, nombre)
    puts 'Nueva enfermedad: ' + nombre
    @edad_diagnostico = edad
    @nombre = nombre
  end

  def get_node
    return @node unless @node.nil?
    neo = Neography::Rest.new
    begin
      @node = Neography::Node.find('enfermedad_index', 'nombre', @nombre)
      return @node
    rescue Neography::NeographyError => err
      puts err.message
      @node = neo.create_node('nombre' => @nombre)
      neo.set_label(@node, 'ENFERMEDAD')
      neo.add_node_to_index('enfermedad_index', 'nombre', @nombre, @node)
      return @node
    end
  end

  def self.generate(enfermedades)
    neo = Neography::Rest.new
    enfermedades.each do |enf|
      node = neo.create_node('nombre' => enf)
      neo.set_label(node, 'ENFERMEDAD')
      neo.add_node_to_index('enfermedad_index', 'nombre', enf, node)
    end
  end
end
