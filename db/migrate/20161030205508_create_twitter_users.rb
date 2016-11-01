class CreateTwitterUsers < ActiveRecord::Migration
  def change
    create_table :twitter_users do |t|
      t.string :uid, null: false, index: true
      t.references :user, forreign_key: true, unique: true, null: false
      t.timestamps
    end
  end
end
