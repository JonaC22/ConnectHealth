class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :description
      t.boolean :active
      t.timestamps null: false
    end
  end
end
