class AddUniqueIndexOnPatientDocumentNumber < ActiveRecord::Migration
  def change
    add_index(:patients, :document_number, unique: true)
  end
end
