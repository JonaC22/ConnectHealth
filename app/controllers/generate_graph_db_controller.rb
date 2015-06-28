class GenerateGraphDbController < BaseController

  def generate
    pacientes = @mysql.query('SELECT * FROM pacientes LIMIT 100')
    # nombres_f = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="f"')
    # nombres_m = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="m"')
    # apellidos = @mysql.query('SELECT Apellido FROM pacientes')
    familias = Array.new
    pacientes.each { |paciente|
      fecha_nac=DateTime.strptime(paciente['Fecha_Nac'], "%Y-%m-%d %H:%M:%S")
      date = rand(Date.civil(fecha_nac.year-50, 1, 1)..Date.civil(fecha_nac.year-20, 12, 31))
      # p = Person.create_from_mysql(paciente)
      # padre = Person.new -1,rand(nombres_m.map { |n| return n['Nombre']}),p.surname,rand(Date.civil(Time.at(pacientes).to_date.year-50, 1, 1)..Date.civil(Time.at(pacientes).to_date.year-20, 12, 31)),'m'
      # madre =Person.new -1,rand(nombres_f.map { |n| return n['Nombre']}),rand(apellidos.map { |n| return n['Apellido']}),rand(Date.civil(Time.at(pacientes).to_date.year-38, 1, 1)..Date.civil(Time.at(pacientes).to_date.year-17, 12, 31)),'f'
      # result = Hash.new
      # result['paciente']=p
      # result['padre']=padre
      # result['madre']=madre
      familias.append(date)
    }
    render json:familias
  end

end