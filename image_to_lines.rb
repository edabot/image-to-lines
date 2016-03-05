require 'RMagick'
require 'rvg/rvg'
include Magick

require 'byebug'


def image_to_line
  @x_spacing = 10
  @total_width = 680
  @total_height = 720
  @base_noise = 0.03
  image = get_image
  image = shrink_and_blur(image)
  grayscale_values = get_grayscale_values(image)
  coordinates = make_coordinates(grayscale_values)

  display(coordinates)
end

def get_image
  ImageList.new(File.open("images/source/#{ARGV[0]}"))
end

def shrink_and_blur(image)
  image.resize_to_fit(50).blur_image(radius=0.0, sigma=1.0)
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

def make_coordinates(array)
  new_array = []
  array.each do |row|
    height_row = make_height_row(row)
    new_array << add_x_values(height_row)
  end
  new_array.reverse
end

def make_height_row(row)
  new_row = []
    row.each do |pixel|
      new_row << process_pixel(pixel)
    end
  new_row
end

def process_pixel(pixel_lightness)
  # debugger
  max_level = 65535
  pixel_darkness = max_level - pixel_lightness
  raw_value = 30 + rand(50)
  final_value = raw_value * ((pixel_darkness.to_f / max_level) + @base_noise)
  @total_height - final_value.to_i
end

def add_x_values(row)
  row.each_with_index do |y_value, idx|
    row[idx] = [idx * @x_spacing, y_value]
  end
  row
end

def display(array)
  rvg = RVG.new(@total_width,@total_height) do |canvas|
    canvas.background_fill = 'black'
    margin = (@total_width - (array[0].length - 1) * @x_spacing) / 2
    lines = make_lines(array)
    lines.each_with_index do |line, idx|
      canvas.use(line).translate(margin, 10 * idx - 600)
    end

  end
  rvg.draw.write('display.gif')
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

# array = [[[2,10], [60,100], [90, 44]],
#         [[2,23], [60,80], [90, 10]],
#         [[2,54], [60,60], [90, 30]],
#         [[2,65], [60,40], [90, 50]]
#       ]
# display(array)
