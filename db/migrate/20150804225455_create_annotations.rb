class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.belongs_to :pedigree, index: true
      t.integer :pos_x
      t.integer :pos_y
      t.string :text
      t.timestamps null: false
    end
  end
end
