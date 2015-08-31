class MakePedigreesController < BaseController
  def index
    mysql_connection
    pacientes = @mysql.query('SELECT * FROM pacientes where Nro_Afiliado < 10000 limit 10;')
    nombres_f = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="f" and Nro_Afiliado < 10000 limit 100').map { |n| n['Nombre'] }
    nombres_m = @mysql.query('SELECT Nombre FROM pacientes WHERE Sexo ="m" and Nro_Afiliado < 10000 limit 100').map { |n| n['Nombre'] }
    apellidos = @mysql.query('SELECT Apellido FROM pacientes where Nro_Afiliado <  10000 limit 100').map { |n| n['Apellido'] }
    close_mysql
    # Disease.generate(%w('Cancer de Ovario','Cancer de Mama'))
    pacientes.each do |patient|
      pedigree = Pedigree.create!
      pat = Patient.create!(name: patient['Nombre'], lastname: patient['Apellido'], birth_date: DateTime.strptime(patient['Fecha_Nac'], '%Y-%m-%d %H:%M:%S'), gender: patient['Sexo'], pedigree: pedigree, active: true)
      if pat.gender == 'F' && rand > 0.5
        # nombre_enfermedad = rand > 0.5 ? 'Cancer de Mama' : 'Cancer de Ovario'
        # cancer = Disease.new rand(35..70), nombre_enfermedad
        # p.add_disease(cancer)
        # enf_rel = neo.create_relationship('PADECE', get_node, disease.get_node)
        # neo.reset_relationship_properties(enf_rel, {'edad_diagnostico' => disease.edad_diagnostico})
        # diseases.append(disease)
      end
    end
    render json: {}
  end

  def delete_all_nodes
    @neo.execute_query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r')
    render json: {}
  end
end
