class RemoveIndexFromDocumentNumberAtPatients < ActiveRecord::Migration
  def change
    remove_index :patients, :document_number
  end
end
