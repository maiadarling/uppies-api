class RemoveContainerIdAndStorageFromSites < ActiveRecord::Migration[8.0]
  def change
    remove_column :sites, :container_id, :string
    remove_column :sites, :storage_path, :string
  end
end
