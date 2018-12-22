# frozen_string_literal: true

# Image uploader for posts
class PostImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  storage :file
  process :auto_orient

  def max_pixel_dimensions
    [7680, 7680]
  end

  def store_dir
    slug = "#{model.id / 10_000}/#{model.id / 100}/#{model.id}"

    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{slug}"
  end

  def auto_orient
    manipulate! do |image|
      image.tap(&:auto_orient)
    end
  end

  version :hd do
    resize_to_fit(1920, 1920)
  end

  version :big, from_version: :hd do
    resize_to_fit(1280, 1280)
  end

  version :medium, from_version: :big do
    resize_to_fit(640, 640)
  end

  version :small, from_version: :medium do
    resize_to_fit(320, 320)
  end

  version :preview_2x, from_version: :small do
    resize_to_fit(160, 160)
  end

  version :preview, from_version: :preview_2x do
    resize_to_fit(80, 80)
  end

  def extension_white_list
    %w[jpg jpeg png]
  end
end
