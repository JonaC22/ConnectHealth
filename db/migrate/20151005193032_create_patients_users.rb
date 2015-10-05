class CreatePatientsUsers < ActiveRecord::Migration
  def change
    create_table :patients_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :patient, index: true
      t.timestamps null: false
    end
  end
end
