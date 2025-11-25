#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

COL_COUNT = 3

def main
  success ,options = parse_options
  return unless success

  if options[:l]
    entry_names_infos = create_entry_names_infos
    total_blocks = create_total_blocks
    put_entry_names_infos(total_blocks, entry_names_infos)
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

def create_entry_names_infos
  entry_names_infos = []
  Dir.glob('*').each do |entry_name|
    entry_names_info = []
    stat = File::Stat.new(entry_name)
    stat_mode = stat.mode.to_s(8)
    stat_mode_length_six = add_zero(stat_mode)
    entry_names_info << get_file_mode(stat_mode_length_six, entry_name)
    entry_names_info << stat.nlink.to_s
    entry_names_info << get_owner_name(stat)
    entry_names_info << get_group_name(stat)
    entry_names_info << get_file_size(stat)
    updated_day = File.mtime(entry_name)
    get_updated_dates(updated_day).each do |updated_date|
      entry_names_info << updated_date
    end
    entry_names_info << entry_name
    entry_names_infos << entry_names_info
  end
  align_width(entry_names_infos)
end

def create_total_blocks
  total_blocks = 0
  Dir.glob('*').each do |entry_name|
    stat = File::Stat.new(entry_name)
    total_blocks += stat.blocks
  end
  total_blocks
end

def add_zero(stat_mode)
  if stat_mode.to_s.length == 5
    "0#{stat_mode}"
  else
    stat_mode
  end
end

def get_file_mode(stat_mode, entry_name)
  file_mode = []
  file_mode << get_file_type(stat_mode)
  file_mode << get_file_permission(stat_mode)
  file_mode << get_extended_attributes(entry_name)
  file_mode.join('')
end

def get_file_type(stat_mode)
  file_type = {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }
  file_type[stat_mode[0, 2]]
end

def get_file_permission(stat_mode)
  file_permission_infos = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }
  stat_mode[3..5].chars.map { |stat_mode_digit| file_permission_infos[stat_mode_digit] }.join
end

def get_extended_attributes(file_name)
  attrs = `xattr #{file_name}`.split("\n")
  return if attrs.empty?

  '@'
end

def get_owner_name(stat)
  uid = stat.uid
  Etc.getpwuid(uid).name
end

def get_group_name(stat)
  Etc.getgrgid(stat.gid).name
end

def get_file_size(stat)
  stat.size.to_s
end

def get_updated_dates(updated_day)
  updated_date = []
  now = DateTime.now
  six_month_ago = now << 6
  updated_date << updated_day.month.to_s
  updated_date << updated_day.day.to_s
  six_month_ago_flag = six_month_ago >= updated_day.to_datetime
  updated_date << (six_month_ago_flag ? updated_day.year.to_s : "#{format('%02d', updated_day.hour)}:#{format('%02d', updated_day.min)}")
end

def put_entry_names_infos(total_blocks, entry_names_infos)
  puts "total #{total_blocks}"
  entry_names_infos.map do |entry_names_info|
    puts entry_names_info.join(' ')
  end
end

def align_width(entry_names_infos)
  max_widths = entry_names_infos.transpose.map do |column|
    column.map(&:length).max
  end

  entry_names_infos.map do |row|
    row.map.with_index do |cell, index|
      if [0, 8].include?(index)
        cell.ljust(max_widths[index])
      else
        cell.rjust(max_widths[index])
      end
    end
  end
end

main
