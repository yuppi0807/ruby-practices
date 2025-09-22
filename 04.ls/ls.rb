# frozen_string_literal: true

COL_COUNT = 4

def main
  entry_names = Dir.glob('*')
  max_width = entry_names.map(&:size).max
  shape_entry_names = shape_entry_names(entry_names)
  puts_and_shape_width(shape_entry_names, max_width)
end

def shape_entry_names(entry_names)
  slice_size = (entry_names.size / COL_COUNT.to_f).ceil

  entry_names = entry_names.each_slice(slice_size).to_a
  shape_entry_names = arrange_size(entry_names, entry_names[0].size)
  shape_entry_names.transpose
end

def arrange_size(entry_names, size)
  entry_names.each do |entry_name|
    entry_name.fill(nil, size...size)
  end
  entry_names
end

def puts_and_shape_width(entry_names, width)
  entry_names.each do |row|
    row.each do |col|
      print col.to_s.ljust(width + 2)
    end
    puts
  end
end

main
