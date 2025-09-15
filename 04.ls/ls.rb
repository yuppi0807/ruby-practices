# frozen_string_literal: true

COL_COUNT_OVER = 1
COL_COUNT_UNDER = 2
COL_COUNT = 3

def main
  entry_names = Dir.glob('*').reject { |entry_name| entry_name == File.basename($PROGRAM_NAME) }
  max_width = entry_names.map(&:size).max
  shape_entry_names, col_count_size = shape_entry_names(entry_names)
  puts_and_shape_width(shape_entry_names, max_width, col_count_size)
end

def shape_entry_names(entry_names)
  return entry_names, COL_COUNT_UNDER if entry_names.size <= COL_COUNT

  slice_size = (entry_names.size / COL_COUNT.to_f).ceil

  entry_names = entry_names.each_slice(slice_size).to_a
  shape_entry_names = arrange_size(entry_names, entry_names[0].size)
  [shape_entry_names.transpose, COL_COUNT_OVER]
end

def arrange_size(entry_names, size)
  entry_names.each do |entry_name|
    entry_name.fill(nil, size...size)
  end
  entry_names
end

def puts_and_shape_width(entry_names, width, col_count_size)
  case col_count_size
  when COL_COUNT_OVER
    entry_names.each do |row|
      row.each do |col|
        print col.to_s.ljust(width + 2)
      end
      puts
    end
  when COL_COUNT_UNDER
    entry_names.each do |entry_name|
      puts entry_name
    end
  end
end

main
