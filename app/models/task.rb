class Task < ApplicationRecord
  belongs_to :user

  enum status: {
    pending: 0,
    in_progress: 1,
    finished: 2,
    failed: 3
  }

  validates :status, presence: true
  validates :user_id, presence: true

  serialize :scraped_data, JSON
end
