class AddNameToFunctions < ActiveRecord::Migration
  def change
    add_column :functions, :name, :string
  end
end
