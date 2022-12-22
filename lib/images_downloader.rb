# frozen_string_literal: true

require './lib/assets_downloader'

class ImagesDownloader
  def initialize(driver, target_url, assets_directory)
    @target_uri = URI(target_url)
    @base_downloader = AssetsDownloader.new(@target_uri)
    @assets_directory = assets_directory
    @driver = driver
  end

  def download
    puts "Downloading images"
    srcs = collect_srcs
    assets_map = @base_downloader.download(@assets_directory, downloadable_srcs(srcs))

    { assets_map: assets_map, total_count: srcs.count }
  end

  private

  def collect_srcs
    elements = @driver.find_elements(xpath: '//picture/source') + @driver.find_elements(:tag_name, 'img')

    [].tap do |srcs|
      elements.each do |element|
        src = element.attribute('src')
        srcset = element.attribute('srcset')

        srcs << src if src != ''

        if srcset != ''
          srcs.concat(srcset.split("\n").map { |src| src.split.first })
        end
      end
    end.compact
  end

  def downloadable_srcs(srcs)
    srcs.reject do |src|
      file_extension = File.extname(src)
      src.start_with?('data:image') || file_extension == ''
    end
  end
end
