require 'RMagick'
require 'rvg/rvg'
include Magick

image = ImageList.new(File.open(ARGV[0]))

black_and_white_image = image.separate(GrayChannel)
image.write("#{ARGV[0][0..-5]}-transposed.jpg")


shrunken_image = image.resize_to_fit(100).blur_image(radius=0.0, sigma=1.0)
shrunken_image.write("#{ARGV[0][0..-5]}-shrunk100.jpg")

rows = shrunken_image.rows
cols =  shrunken_image.columns
array = []
# rows.times do |row|
#   array << image.dispatch(0, 0, cols, row, "I" )
# end

row_data = shrunken_image.dispatch(0, 50, cols, 1, "I" )


def process_row(row)
  new_row = []
  row.each do |pixel|
    new_row << process_pixel(pixel)
  end
  new_row
end

def process_pixel(pixel)
  if pixel > 32000
    light_process
  else
    dark_process
  end
end

def dark_process
  30 + rand(70)
end

def light_process
  rand(10)
end

p process_row(row_data)

p row_data

puts "rows: #{rows}"
puts "cols: #{cols}"
exit
