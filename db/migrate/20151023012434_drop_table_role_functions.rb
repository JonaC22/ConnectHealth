class DropTableRoleFunctions < ActiveRecord::Migration
  def change
    drop_table :role_functions
  end
end
