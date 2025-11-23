class CreateDomainNames < ActiveRecord::Migration[8.0]
  def change
    create_table :domain_names do |t|
      t.references :site, null: false, foreign_key: true
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
