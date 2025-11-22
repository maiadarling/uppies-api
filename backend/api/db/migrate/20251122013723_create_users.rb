class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :token, null: false
      t.timestamps
    end

    add_index :users, :email_address, unique: true
    add_index :users, :token, unique: true
  end
end
