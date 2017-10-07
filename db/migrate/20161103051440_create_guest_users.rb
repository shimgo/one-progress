class CreateGuestUsers < ActiveRecord::Migration
  def change
    create_table :guest_users do |t|
      t.references :user, foreign_key: true, unique: true, null: false

      t.timestamps
    end
  end
end
