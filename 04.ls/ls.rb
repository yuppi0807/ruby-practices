# frozen_string_literal: true

def main
  entry_names = fetch_entry_names
  entry_names = delete_file_name(entry_names, myself_file_name)
  max_width = get_max_width(entry_names)
  shape_entry_names = shape_entry_names(entry_names)
  puts_and_shape_width(shape_entry_names, max_width)
end

def fetch_entry_names
  entry_names = []
  Dir.glob('*') do |entry_name|
    entry_names.push(entry_name)
  end
  entry_names
end

def myself_file_name
  File.basename($PROGRAM_NAME)
end

def delete_file_name(entry_names, deletion_file_name)
  entry_names.reject { |e| e == deletion_file_name }
end

def get_max_width(list)
  list.map { |s| get_width(s) }.max
end

def get_width(str)
  str.codepoints.inject(0) { |a, e| a + (e < 256 ? 1 : 2) }
end

def shape_entry_names(entry_names)
  shape_entry_names = if entry_names.size <= 9
                        shape_under_than_specified(entry_names)
                      else
                        shape_over_than_specified(entry_names)
                      end
  shape_entry_names.transpose
end

def shape_under_than_specified(entry_names)
  columns = [[], [], []]
  number = 0
  entry_names.each_with_index do |entry_name, _index|
    if number < 3
      columns[0].push(entry_name)
      number += 1
    elsif number < 6
      columns[1].push(entry_name)
      number += 1
    elsif number < 9
      columns[2].push(entry_name)
      if number == 8
        number = 0
      else
        number += 1
      end
    end
  end
  shape_list_size(columns[0], columns[1], columns[2])
end

def shape_list_size(base_list, target_list1, target_list2)
  mainsize = base_list.size
  target_list1.push(nil) until target_list1.size == mainsize
  target_list2.push(nil) until target_list2.size == mainsize
  [base_list, target_list1, target_list2]
end

def shape_over_than_specified(entry_names)
  column1 = []
  column2 = []
  column3 = []
  entry_names_surplus = entry_names.size % 3
  number = if entry_names_surplus.zero?
             entry_names.size / 3
           else
             entry_names.size / 3 + 1
           end
  number.times do
    column1.push(entry_names.shift)
  end
  number.times do
    column2.push(entry_names.shift)
  end
  number.times do
    column3.push(entry_names.shift)
  end
  [column1, column2, column3]
end

def puts_and_shape_width(entry_names, width)
  entry_names.each do |row|
    row.each do |col|
      if col.nil?
        print ' ' * (width + 2)
      else
        print col.ljust(width + 2)
      end
    end
    puts
  end
end

main
