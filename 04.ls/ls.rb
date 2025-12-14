#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

COL_COUNT = 3
BEFORE_MONTH = 6

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
  entry_info_table = get_entry_names.map do |entry_name|
    entry_info = {}
    stat = File::Stat.new(entry_name)
    stat_mode,entry_info[:file_mode] = get_file_mode(stat, entry_name)
    entry_info[:nlink] = stat.nlink.to_s
    entry_info[:owner_name] = get_owner_name(stat)
    entry_info[:group_name] = get_group_name(stat)
    entry_info[:file_size] = stat.size.to_s
    updated_day = File.mtime(entry_name)
    entry_info[:updated_dates] = get_updated_dates(updated_day)
    entry_info[:entry_name] = entry_name
    entry_info
  end
  align_width(entry_info_table)
end

def create_total_blocks
  get_entry_names.sum do |entry_name|
    File::Stat.new(entry_name).blocks
  end
end

def get_entry_names
  Dir.glob('*')
end

def get_file_mode(stat, entry_name)
  stat_mode = stat.mode.to_s(8)
  aligned_stat_mode = stat_mode.rjust(6, '0')
  file_type = FILE_TYPES[aligned_stat_mode[0, 2]]
  file_permission = get_file_permission(aligned_stat_mode)
  extended_attributes = get_extended_attributes(entry_name)
  [stat_mode,"#{file_type}#{file_permission}#{extended_attributes}"]
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
  before_date = (Date.today << BEFORE_MONTH).to_time
  before_date_flag = before_date >= updated_day
  updated_date_format = before_date_flag ? '%_m %e %_5Y' : '%_m %e %H:%M'
  updated_day.strftime(updated_date_format)
end

def put_entry_names_infos(total_blocks, entry_info_table)
  puts "total #{total_blocks}"
  entry_info_table.map do |entry_info|
    puts entry_info.join(' ')
  end
end

def align_width(entry_info_table)
  keys = entry_info_table.first.keys
  max_widths_list = get_max_width_list(keys, entry_info_table)
  entry_info_table.map do |row|
    keys.map do |key|
      if %i[file_mode entry_name owner_name group_name].include?(key)
        row[key].ljust(max_widths_list[key])
      else
        row[key].rjust(max_widths_list[key])
      end
    end
  end
end

def get_max_width_list(keys, entry_info_table)
  keys.to_h do |key|
    [key, entry_info_table.map { |row| row[key].to_s.length }.max]
  end
end

main
