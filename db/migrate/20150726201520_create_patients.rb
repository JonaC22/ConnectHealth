class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.belongs_to :pedigree, index: true
      t.string :name
      t.string :lastname
      t.string :document_type
      t.string :document_number
      t.boolean :active, default: false, index: true
      t.timestamps null: false
    end
  end
end
