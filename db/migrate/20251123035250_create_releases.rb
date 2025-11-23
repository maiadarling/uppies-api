class CreateReleases < ActiveRecord::Migration[8.0]
  def change
    create_table :releases do |t|
      t.references :site, null: false, foreign_key: true
      t.references :deployed_by, null: false, foreign_key: { to_table: :users }
      t.string :container_id
      t.string :storage_path, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
