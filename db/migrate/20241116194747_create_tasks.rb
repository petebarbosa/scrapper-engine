class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.string :url_to_scrape, null: false
      t.integer :status, default: 0
      t.json :scraped_data
      t.text :error_message

      t.timestamps
    end
  end
end
