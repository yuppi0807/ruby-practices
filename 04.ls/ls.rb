#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'
require 'debug'

COL_COUNT = 3

FILE_TYPES = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze

FILE_PERMISSION_TABLES = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

FIRST_COL = 0

def main
  success, options = parse_options
  return unless success

  if options[:l]
    entry_info_table = create_entry_info_table
    total_blocks = create_total_blocks
    put_entry_names_infos(total_blocks, entry_info_table)
  else
    entry_names = Dir.glob('*')
    max_width = entry_names.map(&:size).max
    entry_name_table = convert_list_to_table(entry_names)
    puts_table(entry_name_table, max_width)
  end
end

def parse_options
  options = { l: false }
  OptionParser.new do |opts|
    opts.on('-l') { options[:l] = true }
  end.parse!
  [true, options]
rescue OptionParser::InvalidOption
  puts '不正なオプションです'
  [false, nil]
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

def create_entry_info_table
  entry_info_table = Dir.glob('*').map do |entry_name|
    entry_info = []
    stat = File::Stat.new(entry_name)
    stat_mode = stat.mode.to_s(8)
    entry_info << get_file_mode(stat_mode, entry_name)
    entry_info << stat.nlink.to_s
    entry_info << get_owner_name(stat)
    entry_info << get_group_name(stat)
    entry_info << stat.size.to_s
    updated_day = File.mtime(entry_name)
    get_updated_dates(updated_day).each do |updated_date|
      entry_info << updated_date
    end
    entry_info << entry_name
  end
  align_width(entry_info_table)
end

def create_total_blocks
  Dir.glob('*').sum do |entry_name|
    File::Stat.new(entry_name).blocks
  end
end

def get_file_mode(stat_mode, entry_name)
  aligned_stat_mode = stat_mode.to_s.length == 5 ? stat_mode.rjust(6, '0') : stat_mode
  file_mode = []
  file_mode << get_file_type(aligned_stat_mode)
  file_mode << get_file_permission(aligned_stat_mode)
  file_mode << get_extended_attributes(entry_name)
  file_mode.join
end

def get_file_type(stat_mode)
  FILE_TYPES[stat_mode[0, 2]]
end

def get_file_permission(stat_mode)
  stat_mode[3..5].chars.map { |digit| FILE_PERMISSION_TABLES[digit] }.join
end

def get_extended_attributes(file_name)
  attrs = `xattr #{file_name}`
  attrs.empty? ? ' ' : '@'
end

def get_owner_name(stat)
  Etc.getpwuid(stat.uid).name
end

def get_group_name(stat)
  Etc.getgrgid(stat.gid).name
end

def get_updated_dates(updated_day)
  today = Date.today
  six_month_ago = today << 6
  six_month_ago_flag = six_month_ago >= updated_day.to_datetime
  updated_date = six_month_ago_flag ? updated_day.strftime('%-m %-d %Y') : updated_day.strftime('%-m %-d %H:%M')
  updated_date.split(' ')
end

def put_entry_names_infos(total_blocks, entry_info_table)
  puts "total #{total_blocks}"
  entry_info_table.map do |entry_info|
    puts entry_info.join(' ')
  end
end

def align_width(entry_info_table)
  max_widths = entry_info_table.transpose.map do |column|
    column.map(&:length).max
  end

  entry_info_table_width = entry_info_table.map do |row|
    [max_widths, row].transpose
  end

  entry_info_table_width.map do |row|
    max_col = row.size
    row.map.with_index do |col, index|
      if [FIRST_COL, max_col - 1].include?(index)
        col[1].ljust(col[0])
      else
        col[1].rjust(col[0])
      end
    end
  end
end

main
