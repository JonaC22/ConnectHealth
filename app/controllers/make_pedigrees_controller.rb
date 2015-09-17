class MakePedigreesController < BaseController
  def index
    mysql_connection
    pacientes = @mysql.query('SELECT * FROM pacientes where Nro_Afiliado < 10000 limit 10;')
    nombres_f = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="f" and Nro_Afiliado < 10000 limit 100').map { |n| n['Nombre'] }
    nombres_m = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="m" and Nro_Afiliado < 10000 limit 100').map { |n| n['Nombre'] }
    apellidos = @mysql.query('SELECT Apellido FROM pacientes where Nro_Afiliado <  10000 limit 100').map { |n| n['Apellido'] }
    close_mysql
    pedigrees = []
    Disease.generate(['Cancer de Ovario', 'Cancer de Mama'])
    pacientes.each do |patient|
      pedigree = Pedigree.create!
      pat = Patient.create!(name: patient['Nombre'], lastname: patient['Apellido'], birth_date: DateTime.strptime(patient['Fecha_Nac'], '%Y-%m-%d %H:%M:%S'), gender: patient['Sexo'], pedigree: pedigree, active: true, status: 'alive')
      if pat.gender == 'F' && rand > 0.5
        nombre_enfermedad = rand > 0.5 ? 'Cancer de Mama' : 'Cancer de Ovario'
        pat.add_disease(nombre_enfermedad, rand(35..70))
      end
      father = pat.generate_father(name: nombres_m.sample)
      mother = pat.generate_mother(name: nombres_f.sample, lastname: apellidos.sample)
      father.generate_father(name: nombres_m.sample)
      mother.generate_mother(name: nombres_f.sample, lastname: apellidos.sample)
      pedigrees << pedigree
    end
    render json: pedigrees
  end

  def delete_all_nodes
    @neo.execute_query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r')
  end

  def generate_illness(patient)
    return unless patient.gender == 'F' && rand > 0.5
    nombre_enfermedad = rand > 0.5 ? 'Cancer de Mama' : 'Cancer de Ovario'
    patient.add_disease(nombre_enfermedad, rand(35..70))
  end
end
