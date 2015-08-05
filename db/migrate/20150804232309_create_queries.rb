class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
    	t.string :statement
    	t.string :description
    	t.string :result
    	t.belongs_to :user, index: true
    	t.belongs_to :pedigree, index: true
      	t.timestamps null: false
    end
  end
end
