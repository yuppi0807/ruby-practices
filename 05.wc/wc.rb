#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

LEFT_ALIGNMENT_COLS = %i[
  line
  word
  byte
].freeze

require 'debug'

def main
  options = parse_options
  files = build_input
  puts_metadata(options[:non_options], options[:option], files)
end

def parse_options
  options = { l: false, w: false, c: false }
  OptionParser.new do |opts|
    opts.on('-l') { options[:l] = true }
    opts.on('-w') { options[:w] = true }
    opts.on('-c') { options[:c] = true }
  end.parse!

  return { non_options: true, option: options } unless options.values_at(:l, :w, :c).any?

  { non_options: false, option: options }
rescue OptionParser::InvalidOption
  abort '不正なオプションです'
end

def build_input
  if ARGV.any?
    ARGV.map do |path|
      {
        filename: path,
        contents: File.read(path)
      }
    end
  else
    [
      {
        filename: nil,
        contents: ARGF.read
      }
    ]
  end
end

def puts_metadata(non_options, options, files)
  keys, metadata_list = make_metadata_list(non_options, options, files)
  max_widths = make_max_widths(keys, metadata_list)
  metadata_list.each do |metadata|
    cols = keys.map do |key|
      if LEFT_ALIGNMENT_COLS.include?(key)
        metadata[key].to_s.rjust(max_widths[key])
      else
        metadata[key].to_s.ljust(max_widths[key])
      end
    end
    puts cols.join(' ')
  end
end

def make_metadata_list(non_options, options, files)
  metadata_list = files.map { |file| file_metadata(non_options, options, file) }
  keys = metadata_list[0].keys
  metadata_list << make_total_metadata(keys, metadata_list) if metadata_list.size > 1

  [keys, metadata_list]
end

def file_metadata(non_options, options, file)
  contents = file[:contents]
  metadata = {}
  metadata[:line] = make_line(contents) if options[:l] || non_options
  metadata[:word] = make_word(contents) if options[:w] || non_options
  metadata[:byte] = make_byte(contents) if options[:c] || non_options
  metadata[:path] = file[:filename]

  metadata
end

def make_max_widths(keys, metadata_list)
  keys.to_h do |key|
    [key, metadata_list.map { |m| m[key].to_s.length }.max]
  end
end

def make_total_metadata(keys, metadata_list)
  total_metadata = keys.to_h do |key|
    [key, metadata_list.map { |m| m[key].to_i }.sum]
  end
  total_metadata[:path] = 'total'
  total_metadata
end

def make_line(input)
  input.each_line.count.to_s
end

def make_word(input)
  input.split.size.to_s
end

def make_byte(input)
  input.bytesize.to_s
end

main
