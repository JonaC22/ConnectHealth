class AddNodeToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :node, :string
  end
end
