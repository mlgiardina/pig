require_relative '../db/setup'
require_relative './player'
require_relative './saved_game'

class Pig
  def initialize
    @players   = []
    @max_score = 100
    @saved_game = SavedGame.new
  end

  def start_game
    puts "You have #{SavedGame.count} saved games."
    puts "(0) New Game"
    SavedGame.all.each do |save|
      puts "(#{save.id}) #{save.names}"
    end

    response = gets.chomp.to_i

    if response == 0
      get_players
    elsif response > 0
      @loaded_save = SavedGame.find(response)
      split_scores = @saved_game.serialized_scores.split("~")
      split_names = @saved_game.serialized_names.split("~")
      split_names.each do |name|
        @players.push(Player.new(name))
      end
      @players.each_with_index do |player, index|
        player.score = split_scores[index]
      end
    end
  end

  def get_players
    puts "Getting player names. Type q when done."
    loop do
      print "Player #{@players.count + 1}, what is your name? > "
      input = gets.chomp
      if input == "q" || input == ""
        return
      else
        @players.push Player.new(input)
      end
    end
  end

  def play_round
    @players.each do |p|
      puts "\n\nIt is #{p.name}'s turn! You have #{p.score} points. (Press ENTER)"
      gets
      take_turn p
    end
    remove_losing_players!
  end

  def remove_losing_players!
    if @players.any? { |p| p.score > @max_score }
      max_score = @players.map { |p| p.score }.max
      @players = @players.select { |p| p.score == max_score }
    end
  end

  def winner
    if @players.length == 1
      @players.first.name
    end
  end

  def take_turn player
    turn_total = 0
    loop do
      roll = rand 1..6
      if roll == 1
        puts "You rolled a 1. No points for you!"
        return
      else
        turn_total += roll
        puts "You rolled a #{roll}. Turn total is #{turn_total}. Again?"
        if gets.chomp.downcase == "n"
          puts "Stopping with #{turn_total} for the turn."
          player.score += turn_total
          return
        end
      end
      save_game!
    end
  end

  def save_game!
    serialized_scores = ""
    serialized_names = ""
    @players.each do |player|
      serialized_scores += player.score.to_s + "~"
      serialized_names += player.name + "~"
    end
    @saved_game.scores = serialized_scores
    @saved_game.names = serialized_names
    @saved_game.save_game
  end
end

game = Pig.new
game.start_game
game.play_round until game.winner
puts "#{game.winner} wins!"

