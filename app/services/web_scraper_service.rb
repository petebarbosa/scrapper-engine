require 'ferrum'
require 'nokogiri'

class WebScraperService
  URL_PATTERN = %r{/comprar/([^/]+)/([^/]+)/}

  def initialize(task)
    @task = task
    @browser = Ferrum::Browser.new(
      timeout: 20,
      window_size: [1366, 768],
      headless: true,
      browser_options: {
        'disable-web-security': true,
        'disable-site-isolation-trials': true,
        'incognito': true,
        'disable-sync': true,
        'disable-save-password-bubble': true,
        'disable-notifications': true,
        'disable-extensions': true,
        'disable-plugins': true
      },
      browser_path: "/usr/bin/brave-browser"
    )
  end

  def perform_scraping
    @task.update(status: "in_progress")

    begin
      url_match = URL_PATTERN.match(@task.url_to_scrape)
      raise "Invalid URL format" unless url_match

      brand = url_match[1]
      model = url_match[2]

      @browser.goto(@task.url_to_scrape)

      @browser.network.wait_for_idle
      @browser.evaluate('window.scrollBy(0, 300)')
      price_text = nil
      selector = '.VehicleDetailsFipe__price__value'

      @browser.wait_for_selector(selector, timeout: 5)
      element = @browser.at_css(selector)
      if element
        price_text = element.text
      end

      raise "Price element not found" unless price_text

      price = price_text.gsub(/[^\d]/, '')

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

    rescue Ferrum::TimeoutError => e
      handle_error("Timeout waiting for page to load: #{e.message}")
    rescue Ferrum::Error => e
      handle_error("Browser error: #{e.message}")
    rescue StandardError => e
      handle_error(e.message)
    ensure
      @browser.quit
    end
  end

  private

  def handle_error(message)
    @task.update(
      status: "failed",
      error_message: message
    )
  end
end
