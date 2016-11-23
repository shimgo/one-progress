class AddNickNameToTwitterUsers < ActiveRecord::Migration
  def change
    add_column :twitter_users, :nickname, :string, after: :user_id
  end
end
