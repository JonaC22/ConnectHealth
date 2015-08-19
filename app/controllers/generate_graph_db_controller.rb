class GenerateGraphDbController < BaseController
  def generate
    delete_all_nodes
    mysql_connection
    pacientes = @mysql.query('SELECT * FROM pacientes where Nro_Afiliado < 10000 limit 100;')
    nombres_f = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="f" and Nro_Afiliado < 10000 limit 100').map { |n| n['Nombre'] }
    nombres_m = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="m" and Nro_Afiliado < 10000 limit 100').map { |n| n['Nombre'] }
    apellidos = @mysql.query('SELECT Apellido FROM pacientes where Nro_Afiliado <  10000 limit 100').map { |n| n['Apellido'] }
    Disease.generate(['Cancer de Ovario', 'Cancer de Mama'])
    familias = []
    pedigree = Pedigree.create!
    pacientes.each do |paciente|
      result = {}
      p = Patient.create! patient_create_params(paciente)
      if p.gender == 'F' && rand(10) > rand(4..6)
        nombre_enfermedad = rand(1..2) > 1 ? 'Cancer de Mama' : 'Cancer de Ovario'
        cancer = Disease.new rand(35..70), nombre_enfermedad
        p.add_disease(cancer)
      end
      padre = p.create_father(pedigree, nombres_m.sample)
      madre = p.create_mother(pedigree, nombres_f.sample, apellidos.sample)
      result['paciente'] = p
      result['padre'] = padre
      if rand(10) > rand(4..6)
        nombre_enfermedad = rand(1..2) > 1 ? 'Cancer de Mama' : 'Cancer de Ovario'
        cancer = Disease.new rand(35..70), nombre_enfermedad
        madre.add_disease(cancer)
      end
      result['madre'] = madre
      result['abuelo_pat'] = padre.create_father(pedigree, nombres_m.sample)
      result['abuela_pat'] = padre.create_mother(pedigree, nombres_f.sample, apellidos.sample)
      result['abuelo_mat'] = madre.create_father(pedigree, nombres_m.sample)
      result['abuela_mat'] = madre.create_mother(pedigree, nombres_f.sample, apellidos.sample)
      if rand(10) > rand(4..6)
        nombre_enfermedad = rand(1..2) > 1 ? 'Cancer de Mama' : 'Cancer de Ovario'
        cancer = Disease.new rand(35..70), nombre_enfermedad
        result['abuela_mat'].add_disease(cancer)
      end
      familias.append(result) {}

    end
    close_mysql
    render json: familias
  end


  def delete_all_nodes
    @neo.execute_query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r')
    render json: {}
  end

  def patient_create_params(paciente)
    {
      name: paciente['Nombre'],
      lastname: paciente['Apellido'],
      gender: paciente['Sexo']
      }
  end
end