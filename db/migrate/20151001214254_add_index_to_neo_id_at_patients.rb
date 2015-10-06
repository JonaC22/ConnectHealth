class AddIndexToNeoIdAtPatients < ActiveRecord::Migration
  def change
    add_index :patients, :neo_id
  end
end
