class CreateShortUrl < ActiveRecord::Migration[5.2]
  def change
    create_table :short_urls do |t|
      t.string :title, default: ""
      t.string :url, null: false 
      t.string :short_url, null: false, unique: true
      t.bigint :count, default: 0
      t.timestamps
    end

    add_index :short_urls, :short_url, unique: true
    add_index :short_urls, :url, unique: true
  end
end
