class MakePedigreesController < BaseController
  def index
    p Pedigree.all
    pedigree = Pedigree.new
    p pedigree.valid?
    mysql_connection
    pacientes = @mysql.query('SELECT * FROM pacientes where Nro_Afiliado < 10000 limit 10;')
    nombres_f = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="f" and Nro_Afiliado < 10000 limit 100').map { |n| n['Nombre'] }
    nombres_m = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="m" and Nro_Afiliado < 10000 limit 100').map { |n| n['Nombre'] }
    apellidos = @mysql.query('SELECT Apellido FROM pacientes where Nro_Afiliado <  10000 limit 100').map { |n| n['Apellido'] }
    close_mysql
    pacientes.each do |patient|
      patients = []
      patients << Patient.create!(name: patient['Nombre'], lastname: patient['Apellido'], birth_date: DateTime.strptime(patient['Fecha_Nac'], '%Y-%m-%d %H:%M:%S'), gender: patient['Sexo'])
      begin
        pedigree = Pedigree.create! patients: []
      rescue Exception => e
        p "error"
        puts "#{e.message}\n#{e.backtrace.join("\n")}"
      end
      pedigree.patients = patients
      p pedigree
      pedigree.save!
    end
    render json: {}
  end
end
