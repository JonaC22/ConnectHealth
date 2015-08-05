class CreatePedigrees < ActiveRecord::Migration
  def change
    create_table :pedigrees do |t|
    	t.belongs_to :patient, index: true
      	t.timestamps null: false
    end
  end
end
