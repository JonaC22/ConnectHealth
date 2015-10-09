class AddNeoIdToDiseases < ActiveRecord::Migration
  def change
    add_column :diseases, :neo_id, :integer
    add_index :diseases, :neo_id
  end
end
