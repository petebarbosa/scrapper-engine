class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.string :url_to_scrape
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.json :scraped_data

      t.timestamps
    end
  end
end
