#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

LEFT_ALIGNMENT_COLS = %i[
  line
  word
  byte
].freeze

def main
  success, non_options, options = parse_options
  return unless success

  if $stdin.tty?
    puts_metadata(non_options, options)
  else
    puts_stdindata(non_options, options)
  end
end

def parse_options
  options = { l: false, w: false, c: false }
  OptionParser.new do |opts|
    opts.on('-l') { options[:l] = true }
    opts.on('-w') { options[:w] = true }
    opts.on('-c') { options[:c] = true }
  end.parse!

  return [true, true, options] unless options.values_at(:l, :w, :c).any?

  [true, false, options]
rescue OptionParser::InvalidOption
  puts '不正なオプションです'
  [false, nil, nil]
end

def puts_metadata(non_options, options)
  keys, metadata_list = make_metadata_list(non_options, options)
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

def make_metadata_list(non_options, options)
  metadata_list = paths.map { |path| file_metadata(path, non_options, options) }
  keys = metadata_list[0].keys
  metadata_list << make_total_metadata(keys, metadata_list) if metadata_list.size > 1

  [keys, metadata_list]
end

def file_metadata(path, non_options, options)
  metadata = {}
  metadata[:line] = File.readlines(path).size if options[:l] || non_options
  metadata[:word] = File.read(path).split.size if options[:w] || non_options
  metadata[:byte] = File.stat(path).size if options[:c] || non_options
  metadata[:path] = path
  metadata
end

def paths
  ARGV
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

def puts_stdindata(non_options, options)
  stdindata = make_stdindata(non_options, options)
  puts stdindata.values.join(' ')
end

def make_stdindata(non_options, options)
  input = ARGF.read
  stdindata = {}
  stdindata[:line] = make_stdin_line(input) if options[:l] || non_options
  stdindata[:word] = make_stdin_word(input) if options[:w] || non_options
  stdindata[:byte] = make_stdin_byte(input) if options[:c] || non_options
  stdindata
end

def make_stdin_line(input)
  input.each_line.count.to_s
end

def make_stdin_word(input)
  input.split.size.to_s
end

def make_stdin_byte(input)
  input.bytesize.to_s
end

main
