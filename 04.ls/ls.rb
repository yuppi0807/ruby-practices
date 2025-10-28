# frozen_string_literal: true

require 'optparse'

COL_COUNT = 3
@options = { a: false }

def analyze_options
  OptionParser.new do |opts|
    opts.on('-a') { @options[:a] = true }
  end.parse!
  if @options[:a]
    entry_names = Dir.glob('*', File::FNM_DOTMATCH)
    main(entry_names)
  elsif ARGV.empty?
    entry_names = Dir.glob('*')
    main(entry_names)
  end
rescue OptionParser::InvalidOption
  puts '出力範囲外のオプションです'
end

def main(entry_names)
  max_width = entry_names.map(&:size).max
  entry_name_table = convert_list_to_table(entry_names)
  puts_table(entry_name_table, max_width)
end

def convert_list_to_table(entry_names)
  row_size = entry_names.size.ceildiv(COL_COUNT)
  entry_name_table_blanks = entry_names.each_slice(row_size).to_a
  entry_name_table = fill_blanks(entry_name_table_blanks, row_size)
  entry_name_table.transpose
end

def fill_blanks(entry_name_table_blanks, row_size)
  entry_name_table_blanks.map do |entry_names|
    entry_names + Array.new(row_size - entry_names.length)
  end
end

def puts_table(entry_name_table, max_width)
  entry_name_table.each do |entry_names|
    entry_names.each do |entry_name|
      print entry_name.to_s.ljust(max_width + 2)
    end
    puts
  end
end

analyze_options
