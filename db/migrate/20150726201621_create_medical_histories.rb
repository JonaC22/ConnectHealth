class CreateMedicalHistories < ActiveRecord::Migration
  def change
    create_table :medical_histories do |t|
    	t.belongs_to :patient, index: true
    	t.string :json_text
      	t.timestamps null: false
    end
  end
end
