# frozen_string_literal: true

require 'down'

class AssetsDownloader
  def initialize(target_uri)
    @target_uri = target_uri
  end

  def download(assets_directory, srcs)
    Dir.mkdir(assets_directory) unless File.exist?(assets_directory)

    srcs.each_with_object({}) do |src, assets_map|
      src_full_url = make_src_full_url(src)
      file_extension = File.extname(src)

      destination_file_name = "#{assets_directory}/#{Digest::MD5.hexdigest(src_full_url)}#{file_extension}"

      thread = Thread.new { Down.download(src_full_url, destination: destination_file_name) }
      thread.abort_on_exception = true
      thread.report_on_exception = false

      assets_map[src_full_url] =  "./#{destination_file_name}"
    end
  end

  private

  def make_src_full_url(src)
    src_uri = URI(src)

    unless src_uri.host
      src_uri.host = @target_uri.host
      src_uri.scheme = @target_uri.scheme
    end

    src_uri.to_s
  end
end
