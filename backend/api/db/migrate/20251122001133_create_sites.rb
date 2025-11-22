class CreateSites < ActiveRecord::Migration[8.0]
  def change
    create_table :sites do |t|
      t.string :name, null: false
      t.string :storage_path, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :sites, :name, unique: true
  end
end
