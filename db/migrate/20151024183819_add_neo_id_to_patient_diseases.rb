class AddNeoIdToPatientDiseases < ActiveRecord::Migration
  def change
    add_column :patient_diseases, :neo_id, :integer
  end
end
