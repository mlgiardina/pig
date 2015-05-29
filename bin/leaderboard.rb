require_relative '../lib/pig'
require_relative '../lib/hog'
require_relative '../lib/top.rb'

leaderboard = Top.order(wins: :desc)
puts "---Leaderboard---"
leaderboard.each { |player| puts player.name + ": " + player.wins.to_s }
