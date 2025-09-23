# frozen_string_literal: true

COL_COUNT = 4

def main
  entry_names = Dir.glob('*')
  max_width = entry_names.map(&:size).max
  shape_entry_names = arrange_entry_names(entry_names)
  puts_like_ls(shape_entry_names, max_width)
end

def arrange_entry_names(entry_names)
  slice_size = entry_names.size.ceildiv(COL_COUNT)
  slice_entry_names = entry_names.each_slice(slice_size).to_a
  shape_entry_names = arrange_size(slice_entry_names, slice_size)
  shape_entry_names.transpose
end

def arrange_size(entry_names, size)
  shape_entry_names = []
  entry_names.each do |entry_name_col|
    shape_entry_names << entry_name_col + [nil] * [0, size - entry_name_col.length].max
  end
  shape_entry_names
end

def puts_like_ls(shape_entry_names, width)
  shape_entry_names.each do |row|
    row.each do |col|
      print col.to_s.ljust(width + 2)
    end
    puts
  end
end

main
