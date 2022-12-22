# frozen_string_literal: true

require 'selenium-webdriver'
require 'digest'
require './lib/images_downloader'
require './lib/css_downloader'

class WebSaver
  def fetch_webpage_and_save_assets_with_metadata(url)
    html_file_name = normalize_url_without_protocol(url)
    html_file_name << '.html' unless html_file_name.end_with?('.html')

    # fetch original html
    html = fetch_html(url)

    # save assets
    save_assets_result = save_assets(url)

    # rewrite assets' paths
    save_assets_result.each do |_type, result|
      result[:assets_map].each do |old_src, new_src|
        old_uri = URI(old_src)
        html.gsub!(old_src, new_src)
        html.gsub!(old_uri.path, new_src)
      end
    end

    # save html
    File.open(html_file_name, 'w') { |file| file.write html }

    # save metadata
    populate_and_save_metadata(url, save_assets_result[:image][:total_count])
  end

  def fetch_metadata(url)
    metadata_file_name = metadata_file_name(url)
    if File.exist?(metadata_file_name)
      puts File.read(metadata_file_name)
    else
      puts "No meta data is found for #{url}"
    end
  end

  def quit_driver
    driver.quit
  end

  private

  def driver
    @driver ||= begin
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--no-sandbox')

      Selenium::WebDriver.for(:remote, options: options, url: 'http://chrome:4444/wd/hub')
      # use this to run without docker
      #Selenium::WebDriver.for(:chrome, options: options)
    end
  end

  # "/" character will be undertood as a folder by file system, it's better to change it to "_"
  def normalize_url_without_protocol(url)
    uri = URI.parse url
    uri.to_s.gsub("#{uri.scheme}://", '').gsub('/', '_')
  end

  def metadata_file_name(url)
    digest = Digest::MD5.hexdigest normalize_url_without_protocol(url)
    "metadata/#{digest}"
  end

  def assets_folder(url)
    digest = Digest::MD5.hexdigest normalize_url_without_protocol(url)
    "assets/#{digest}"
  end

  def fetch_html(url)
    driver.get(url)
    driver.page_source
  end

  def populate_and_save_metadata(url, image_count)
    metadata_file_name = metadata_file_name(url)
    content = ["site: #{url}"]

    num_of_links = driver.find_elements(:tag_name, 'a').count
    content << "num_links: #{num_of_links}"

    content << "images: #{image_count}"

    content << "last_fetch: #{Time.now.utc}"

    File.open(metadata_file_name, 'w') { |file| file.write content.join("\n") }
  end

  def save_assets(url)
    assets_directory = assets_folder(url)

    image_downloader = ImagesDownloader.new(driver, url, assets_directory)
    download_image_result = image_downloader.download

    css_downloader = CSSDownloader.new(driver, url, assets_directory)
    download_css_result = css_downloader.download

    { image: download_image_result, css: download_css_result }
  end
end
