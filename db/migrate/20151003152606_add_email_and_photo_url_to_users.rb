class AddEmailAndPhotoUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :string
    add_column :users, :photo_url, :string
    add_index :users, :email, unique: true
    remove_index :users, :username
    remove_column :users, :username
  end
end
