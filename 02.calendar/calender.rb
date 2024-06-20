#! /usr/bin/env ruby
require 'optparse'
require 'date'

class Calender
  def initialize(year,month)
    @year = year
    @month = month
  end

  def print
    puts print_dayandmonth
    puts print_oneweek
    print_onemonth
  end

  def print_dayandmonth
    "#{@month}月 #{@year}".center(20)
  end

  def print_oneweek
    oneweek_jp = "日 月 火 水 木 金 土"
    return oneweek_jp
  end

  def print_onemonth
    week = []
    #開始曜日に応じて、空白を追加する
    Date.new(@year,@month,1).wday.times{ week << "  " }
    #最初の日から最後の日までを文字列配列にする。
    days = (Date.new(@year,@month,1)..Date.new(@year, @month, -1))
    #一日づつ、weekに渡す。
    days.each do |date|
      week << date.day.to_s.rjust(2)
      if week.size == 7
        puts week.join(' ')
        week.clear
      end
    end
    puts week.join(' ')
  end
end

#今日の日付、西暦を取得する。
options = {year:Date.today.year,month:Date.today.month }  # デフォルトで今日の月を設定
opt = OptionParser.new
opt.on('-y VAL') {|v| options[:year] = v.to_i}
opt.on('-m VAL' ) {|v| options[:month] = v.to_i}
opt.parse!(ARGV)

calender = Calender.new(options[:year],options[:month]);
calender.print
