#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each_with_index do |s, index|
  # ストライクの場合
  if s == 'X'
    shots << 10
    if index >= 16
      next
    else
      shots << 0
    end
  else
    shots << s.to_i
  end
end

# 1ゲームごとに分ける
frames = []
shots.each_slice(2) do |s|
  frames << s
end

# 最終フレームの処理
if frames[10]
  frames[9] << frames[10][0].to_i
  frames.delete_at(10)
end

# 最終フレームにストライクが2回以上あった場合
if frames[10]
  frames[9] << frames[10][0].to_i
  frames.delete_at(10)
  frames[9].delete(0)
end

total_score = 0
frames.each_with_index do |frame, index|
  # 10ゲーム目の場合
  if index == 9
    total_score += frame.sum
  # ストライクの場合
  elsif frame[0] == 10
    strike_ninegame = frames[index + 1][0] == 10 && index == 8
    if strike_ninegame
      total_score += 10 + frames[index + 1][0] + frames[index + 1][1]
    elsif frames[index + 1][0] == 10
      total_score += 20 + frames[index + 2][0]
    else
      total_score += 10 + frames[index + 1][0] + frames[index + 1][1]
    end
  # ストライクの場合
  elsif frame.sum == 10
    total_score += 10 + frames[index + 1][0]
  else
    total_score += frame.sum
  end
end

puts total_score
