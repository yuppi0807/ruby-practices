#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each_with_index do |s, index|
  # ストライクの場合
  if s == 'X'
    shots << 10
    shots << 0 if index < 16
  else
    shots << s.to_i
  end
end

# 1ゲームごとに分ける
frames = []
shots.each_slice(2) do |s|
  frames << s
end

# 8番目までの配列 + 9番目以降の0を取り除いてくっつけたもの（10レーンでストライクが発生した場合）
frames = frames[0..8] + [frames[9..].map { _1 == [10, 0] ? [10] : _1 }.flatten]

total_score = 0
frames.each_with_index do |frame, index|
  # 10ゲーム目の場合
  if index == 9
    total_score += frame.sum
  # ストライクの場合
  elsif frame[0] == 10
    strike_ninegame = frames[index + 1][0] == 10 && index == 8
    total_score += if strike_ninegame
                     10 + frames[index + 1][0] + frames[index + 1][1]
                   elsif frames[index + 1][0] == 10
                     20 + frames[index + 2][0]
                   else
                     10 + frames[index + 1][0] + frames[index + 1][1]
                   end
  # スペアの場合
  elsif frame.sum == 10
    total_score += 10 + frames[index + 1][0]
  else
    total_score += frame.sum
  end
end

puts total_score
