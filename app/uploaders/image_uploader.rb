require 'carrierwave/processing/mini_magick'
class ImageUploader < CarrierWave::Uploader::Base
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{RAILS_ROOT}/tmp/uploads"
  end

  def cache_dir
    "#{RAILS_ROOT}/tmp/uploads"
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  process :resize_to_limit => [80, 80]

  version :logo do
    process :resize_to_fill => [100, 100]
  end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  def extension_white_list
     %w(jpg jpeg gif png)
  end
end
