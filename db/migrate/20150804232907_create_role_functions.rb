class CreateRoleFunctions < ActiveRecord::Migration
  def change
    create_table :role_functions do |t|
    	t.belongs_to :role, index:true
    	t.belongs_to :function, index:true
      	t.timestamps null: false
    end
  end
end
