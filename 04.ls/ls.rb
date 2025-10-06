# frozen_string_literal: true

COL_COUNT = 3

def main
  entry_names = Dir.glob('*')
  max_width = entry_names.map(&:size).max
  arranged_entry_names = arrange_entry_names(entry_names)
  puts_table(arranged_entry_names, max_width)
end

def arrange_entry_names(entry_names)
  sliced_size = entry_names.size.ceildiv(COL_COUNT)
  sliced_entry_names = entry_names.each_slice(sliced_size).to_a
  arranged_entry_names = arrange_size(sliced_entry_names, sliced_size)
  arranged_entry_names.transpose
end

def arrange_size(entry_names, size)
  entry_names.map do |entry_name_col|
    entry_name_col + [nil] * (size - entry_name_col.length)
  end
end

def puts_table(arranged_entry_names, width)
  arranged_entry_names.each do |row|
    row.each do |col|
      print col.to_s.ljust(width + 2)
    end
    puts
  end
end

main
