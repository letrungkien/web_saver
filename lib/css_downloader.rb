# frozen_string_literal: true

require './lib/assets_downloader'

class CSSDownloader
  def initialize(target_url, assets_directory)
    @target_uri = URI(target_url)
    @base_downloader = AssetsDownloader.new(@target_uri)
    @assets_directory = assets_directory
  end

  def download(elements)
    puts "Downloading CSS files"
    srcs = collect_srcs(elements)
    assets_map = @base_downloader.download(@assets_directory, downloadable_srcs(srcs))

    { assets_map: assets_map, total_count: srcs.count }
  end

  private

  def collect_srcs(elements)
    [].tap do |srcs|
      elements.each do |element|
        src = element.attribute('href')
        rel = element.attribute('rel')
        data_href = element.attribute('data-href')
        data_href_extension = File.extname(data_href.to_s)

        srcs << src if src != '' && rel == 'stylesheet'
        srcs << data_href if data_href != '' && data_href_extension == '.css'
      end
    end.compact
  end

  def downloadable_srcs(srcs)
    srcs
  end
end
