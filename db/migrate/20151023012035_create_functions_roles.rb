class CreateFunctionsRoles < ActiveRecord::Migration
  def change
    create_table :functions_roles do |t|
      t.belongs_to :function, index: true
      t.belongs_to :role, index: true
      t.timestamps null: false
    end
  end
end
