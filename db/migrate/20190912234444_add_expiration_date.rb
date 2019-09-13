class AddExpirationDate < ActiveRecord::Migration[5.2]
  def change
    add_column :short_urls, :expires_at, :timestamp
  end
end
