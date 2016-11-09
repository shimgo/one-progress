class RemoveColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string
    rename_column :users, :nickname, :username
    add_column    :users, :is_active, :boolean, after: :image_url, null: false
  end
end
