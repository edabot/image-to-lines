require 'RMagick'
require 'rvg/rvg'
include Magick

require 'byebug'

@x_spacing = 10
@y_spacing = 10
@total_width = 640
@total_height = 640
@base_noise = 0.03
@random_range = 50
@base_height = 20
@image_count = 10
@file_name = ARGV[0][0..-5]

def image_to_line
  image = get_image
  image = shrink_and_blur(image)
  grayscale_values = get_grayscale_values(image)

  Dir.mkdir("images/processed/#{@file_name}") unless File.exists?("images/processed/#{@file_name}")
  @anim = ImageList.new

  @image_count.times do |image_number|
    coordinates = make_coordinates(grayscale_values)
    make_image(coordinates, image_number)
  end

  @anim.write("images/processed/#{@file_name}/#{@file_name}-animated.gif")
end

def get_image
  ImageList.new(File.open("images/source/#{ARGV[0]}"))
end

def shrink_and_blur(image)
  image.resize_to_fit(50).blur_image(radius=0.0, sigma=1.0)
end

# def write_with_suffix(image, suffix)
#   image.write("images/processed/#{ARGV[0][0..-5]}-#{suffix}.jpg")
# end

def get_grayscale_values(image)
  array = []
  image.rows.times do |row|
    array << image.dispatch(0, row, image.columns, 1, "I" )
  end
  array
end

def make_coordinates(array)
  new_array = []
  array.each do |row|
    height_row = make_height_row(row)
    new_array << add_x_values(height_row)
  end
  new_array
end

def averaged_row(row)
  averaged_row = row
  (2..row.length-3).each do |index|
    averaged_row[index] = average_of_five(row, index)
  end
  averaged_row
end

def average_of_three(row, index)
  total = 0
  (index - 1..index + 1).each { |x| total += row[x] }
  total / 3
end

def average_of_five(row,index)
  total = 0
  (index-2..index+2).each { |x| total += row[x] }
  total / 5
end

def make_height_row(row)
  new_row = []
    row.each do |pixel|
      new_row << process_pixel(pixel)
    end
  averaged_row(new_row)
end

def process_pixel(pixel_lightness)
  max_level = 65535
  pixel_darkness = max_level - pixel_lightness
  raw_value = @base_height + rand(@random_range)
  height = raw_value * ((pixel_darkness.to_f / max_level) + @base_noise)
  @total_height - height.to_i
end

def add_x_values(row)
  row.each_with_index do |y_value, idx|
    row[idx] = [idx * @x_spacing, y_value]
  end
  row
end

def make_image(array, image_number)
  rvg = RVG.new(@total_width,@total_height) do |canvas|
    canvas.background_fill = 'black'
    side_margin = (@total_width - (array[0].length - 1) * @x_spacing) / 2
    bottom_margin = (array.length - 1) * @y_spacing + 60
    lines = make_lines(array)
    lines.each_with_index do |line, idx|
      canvas.use(line).translate(side_margin, @y_spacing * idx - bottom_margin)
    end
  end
  @anim << rvg.draw
  rvg.draw.write("images/processed/#{@file_name}/#{@file_name}-#{image_number}.gif")
end

def make_lines(line_data)
  lines = []
  line_data.each do |line|
    lines << make_line(line.flatten)
  end
  lines
end

def make_line(array)
  RVG::Group.new do |line|
    line.styles(:stroke=>'white', :stroke_width=>2,:fill=>'black')
    line.polyline(array)
  end
end

image_to_line
