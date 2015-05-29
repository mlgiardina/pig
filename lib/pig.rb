require_relative '../db/setup'
require_relative './player'
require_relative './saved_game'
require_relative './top'

class Pig
  def initialize
    @players   = []
    @max_score = 100
    @saved_game = SavedGame.new
  end

  def start_game
    puts "Welcome to Pig! Would you like to play a game or see the leaderboard? (play or leaderboard)"
    play_or_leaderboard_response = gets.chomp.downcase
    if play_or_leaderboard_response == "leaderboard"
      system("clear")

      leaderboard = Top.order(wins: :desc)
      puts "---Leaderboard---"
      leaderboard.each { |player| puts player.name + ": " + player.wins.to_s }

      puts "Would you like to exit?"
      leave_choice = gets.chomp.downcase
      if leave_choice == "yes"
        exit
      end
    end

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
      split_scores = @loaded_save.scores.split("~")
      split_names = @loaded_save.names.split("~")
      split_names.each do |name|
        @players.push(Player.new(name))
      end
      @players.each_with_index do |player, index|
        player.score = split_scores[index].to_i
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
        Top.find_or_create_by(name: input, wins: 0)
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
      @players.first
      end_game
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
          save_game!
          return
        end
      end
    end
  end

#-As of right now, if we load a saved game and then quit,
#-it makes a new save rather than overwriting the current save.

  def save_game!
    serialized_scores = ""
    serialized_names = ""
    @players.each do |player|
      serialized_scores += player.score.to_s + "~"
      serialized_names += player.name + "~"
    end
    @saved_game.scores = serialized_scores
    @saved_game.names = serialized_names
    @saved_game.save!
  end

  def end_game
    win_record = Top.find_by(name: @players.first.name)
    win_record.wins = win_record.wins += 1
    win_record.save!
    if @loaded_save
      @loaded_save.destroy
    end
    puts "#{@players.first.name} wins!"
    exit
  end

  trap(:INT) {
    puts "\nSaving and quitting..."
    sleep 0.5
    exit
  }
end


