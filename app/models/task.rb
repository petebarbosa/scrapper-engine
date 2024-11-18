class Task < ApplicationRecord
  belongs_to :user

  VALID_STATUSES = %w[pending in_progress finished failed].freeze

  validates :status, inclusion: { in: VALID_STATUSES }
  validates :user_id, presence: true
  validates :url_to_scrape, presence: true,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }

  # serialize :scraped_data, coder: JSON

  def initialize(attributes = {})
    super
    self.status ||= "pending"
  end
end
