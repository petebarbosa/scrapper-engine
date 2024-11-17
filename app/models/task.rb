class Task < ApplicationRecord
  belongs_to :user

  enum :status, [ :pending, :in_progress, :finished, :failed ], default: :pending

  validates :user_id, presence: true
  validates :url_to_scrape, presence: true,
    format: { with: URI.regexp(%w[http https]), message: "must be a valid URL" }

  serialize :scraped_data, JSON
end
