# frozen_string_literal: true

def acquisition_files_and_directories
  filesanddiries = []
  Dir.glob('*') do |d|
    filesanddiries.push(d)
  end
  filesanddiries
end

def cutsamename
  cutsamename_filesanddiries = acquisition_files_and_directories
  cutsamename_filesanddiries.delete('ls.rb')
  cutsamename_filesanddiries
end

def arrange_list
  cutsamenamelist = cutsamename
  max_width = cutsamenamelist.map { |s| display_width(s) }.max
  list1 = []
  list2 = []
  list3 = []
  number = 0
  if cutsamenamelist.size <= 9
    cutsamenamelist.each_with_index do |fileanddir, _index|
      if number < 3
        list1.push(fileanddir)
        number += 1
      elsif number < 6
        list2.push(fileanddir)
        number += 1
      elsif number < 9
        list3.push(fileanddir)
        if number == 8
          number = 0
        else
          number += 1
        end
      end
    end
    mainsize = list1.size
    list2.push(nil) until list2.size == mainsize
    list3.push(nil) until list3.size == mainsize
  else
    cutsamename_surplus = cutsamenamelist.size % 3
    number = if cutsamename_surplus.zero?
               cutsamenamelist.size / 3
             else
               cutsamenamelist.size / 3 + 1
             end
    number.times do
      list1.push(cutsamenamelist.shift)
    end
    number.times do
      list2.push(cutsamenamelist.shift)
    end
    number.times do
      list3.push(cutsamenamelist.shift)
    end
  end
  union_list = [list1, list2, list3]
  [union_list.transpose, max_width]
end

def display_fileanddir
  use_get_rows_and_columns_list, max_width = arrange_list

  use_get_rows_and_columns_list.each do |row|
    row.each do |col|
      if col.nil?
        print ' ' * (max_width + 2)
      else
        print col.ljust(max_width + 2)
      end
    end
    puts
  end
end

def display_width(str)
  str.codepoints.inject(0) { |a, e| a + (e < 256 ? 1 : 2) }
end
display_fileanddir
