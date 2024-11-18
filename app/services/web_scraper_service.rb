require "open-uri"
require "nokogiri"

class WebScraperService
  URL_PATTERN = %r{/comprar/([^/]+)/([^/]+)/}

  def initialize(task)
    @task = task
  end

  def perform_scraping
    @task.update(status: "in_progress")

    begin
      url_match = URL_PATTERN.match(@task.url_to_scrape)
      raise "Invalid URL format" unless url_match

      brand = url_match[1]
      model = url_match[2]

      doc = Nokogiri::HTML(URI.open(@task.url_to_scrape))
      price_element = doc.at_css(".VehicleDetailsFipe__price__value")
      raise "Price element not found" unless price_element

      price = price_element.text.gsub("R$ ", "").gsub(".", "")

      car_data = {
        brand: brand,
        model: model,
        price: price,
        url: @task.url_to_scrape
      }

      @task.update(
        scraped_data: car_data,
        status: "finished"
      )

      # notify_completion(success: true)

    rescue OpenURI::HTTPError => e
      handle_error("HTTP Error: #{e.message}")
    rescue StandardError => e
      handle_error(e.message)
    end
  end

  private

  def handle_error(message)
    @task.update(
      status: "failed",
      error_message: message
    )

    # notify_completion(success: false, error: message)
  end

  def notify_completion(success:, error: nil)
    notification_data = {
      task_id: @task.id,
      user_id: @task.user_id,
      status: success ? "completed" : "failed",
      scraped_data: @task.scraped_data,
      error: error
    }

    # NotificationService.send(notification_data)
  end
end
