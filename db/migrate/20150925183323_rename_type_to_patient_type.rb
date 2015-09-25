class RenameTypeToPatientType < ActiveRecord::Migration
  def change
    rename_column :patients, :type, :patient_type
  end
end
