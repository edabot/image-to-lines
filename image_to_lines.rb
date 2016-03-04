require 'RMagick'
require 'rvg/rvg'
include Magick

require 'byebug'


def image_to_line
  image = get_image
  image = shrink_and_blur(image)
  grayscale_values = get_grayscale_values(image)
  height_values = grayscale_to_height(grayscale_values)
  p height_values[0]
end

def get_image
  ImageList.new(File.open("images/source/#{ARGV[0]}"))
end

def shrink_and_blur(image)
  image.resize_to_fit(100).blur_image(radius=0.0, sigma=1.0)
end

def write_with_suffix(image, suffix)
  image.write("images/processed/#{ARGV[0][0..-5]}-#{suffix}.jpg")
end

def get_grayscale_values(image)
  array = []
  image.rows.times do |row|
    array << image.dispatch(0, row, image.columns, 1, "I" )
  end
  array
end

def grayscale_to_height(array)
  new_array = []
  array.each do |row|
    new_array << process_row(row)
  end
  new_array
end

def process_row(row)
  new_row = []
    row.each do |pixel|
      new_row << process_pixel(pixel)
    end
  new_row
end

def process_pixel(pixel_lightness)
  # debugger
  pixel_darkness = 65535 - pixel_lightness
  raw_value = 30 + rand(70)
  final_value = raw_value * pixel_darkness.to_f / 65535
  final_value.to_i
end

image_to_line
