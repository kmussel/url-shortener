class CreateShortUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :short_urls do |t|
      t.string :key, null: false
      t.text :source, null: false

      t.timestamps
    end
    add_index :short_urls, :key, unique: true
  end
end
