class AddNeoIdToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :neo_id, :integer
  end
end
