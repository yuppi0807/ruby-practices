# frozen_string_literal: true

COL_COUNT = 3

def main
  entry_names = Dir.glob('*')
  max_width = entry_names.map(&:size).max
  entry_names_table = change_list_to_table(entry_names)
  puts_table(entry_names_table, max_width)
end

def change_list_to_table(entry_names)
  row_size = entry_names.size.ceildiv(COL_COUNT)
  entry_names_table_blanks = entry_names.each_slice(row_size).to_a
  entry_names_table = fill_blanks(entry_names_table_blanks, row_size)
  entry_names_table.transpose
end

def fill_blanks(entry_names_table_blanks, row_size)
  entry_names_table_blanks.map do |entry_names|
    entry_names + [nil] * (row_size - entry_names.length)
  end
end

def puts_table(entry_names_table, max_width)
  entry_names_table.each do |entry_names|
    entry_names.each do |entry_name|
      print entry_name.to_s.ljust(max_width + 2)
    end
    puts
  end
end

main
