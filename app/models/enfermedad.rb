class Enfermedad

  attr_accessor :nombre,:edad_diagnostico

  def initialize(edad, nombre)
    @edad_diagnostico=edad
    @nombre=nombre
  end

end