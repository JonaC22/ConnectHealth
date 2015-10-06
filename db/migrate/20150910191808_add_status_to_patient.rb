class AddStatusToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :status, :integer
  end
end
