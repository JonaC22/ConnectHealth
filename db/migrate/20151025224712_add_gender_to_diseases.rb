class AddGenderToDiseases < ActiveRecord::Migration
  def change
    add_column :diseases, :gender, :integer
  end
end
