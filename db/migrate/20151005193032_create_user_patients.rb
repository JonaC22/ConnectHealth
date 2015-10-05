class CreateUserPatients < ActiveRecord::Migration
  def change
    create_table :user_patients do |t|
      t.belongs_to :user, index: true
      t.belongs_to :patient, index: true
      t.timestamps null: false
    end
  end
end
