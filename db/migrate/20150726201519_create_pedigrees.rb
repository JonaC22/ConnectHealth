class CreatePedigrees < ActiveRecord::Migration
  def change
    create_table :pedigrees do |t|
      t.timestamps null: false
    end
  end
end
