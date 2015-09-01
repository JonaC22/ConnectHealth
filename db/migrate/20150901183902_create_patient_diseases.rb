class CreatePatientDiseases < ActiveRecord::Migration
  def change
    create_table :patient_diseases do |t|
      t.belongs_to :patient, index: true
      t.belongs_to :disease, index: true
      t.integer :age
      t.timestamps
    end
  end
end
