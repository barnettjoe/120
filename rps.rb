require 'pry'

class Move
  VALUES = %w[rock paper scissors spock lizard]

  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def to_s
    @value.capitalize
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end

  def win_round
    self.score += 1
  end
end

class Human < Player
  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard or spock:"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end

  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  RESULTS_ARRAY = ["Scissors cuts Paper",
                   "Paper covers Rock",
                   "Rock crushes Lizard",
                   "Lizard poisons Spock",
                   "Spock smashes Scissors",
                   "Scissors decapitates Lizard",
                   "Lizard eats Paper",
                   "Paper disproves Spock",
                   "Spock vaporizes Rock",
                   "Rock crushes Scissors"].map(&:split)

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
    puts "The first to get 3 points wins."
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def display_round_winner
    if computer.move.value == human.move.value
      puts "This round is a tie."
    else
      winning_player = winner()
      losing_player  = loser()
      display_action(winning_player, losing_player)
      puts "#{winning_player.name} won the round!"
      winning_player.win_round
    end
  end

  def winner
    # this is the main bit of logic where we actually find who won
    human_win = RESULTS_ARRAY.any? do |winning_move, _, losing_move|
      (winning_move.downcase == human.move.value) &&
        (losing_move.downcase == computer.move.value)
    end

    human_win ? human : computer
  end

  def loser
    # whoever is not the winner, must be the loser
    # (we only use this method we have already checked for a tie)
    [human, computer].find { |player| player != winner }
  end

  def display_action(winning_player, losing_player)
    winning_move = winning_player.move.value
    losing_move  = losing_player.move.value

    action = RESULTS_ARRAY.find do |a, _, c|
      a.downcase == winning_move && c.downcase == losing_move
    end

    puts action.join(" ")
  end

  def display_overall_winner
    puts "#{(human.score == 3 ? human : computer).name} won the match!"
  end

  def display_scores
    score = "#{human.name}: #{human.score}, #{computer.name}: #{computer.score}"
    puts "The score is: #{score}"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer)
      puts "Sorry, must be y or n"
    end
    return false if answer.downcase == 'n'
    return true  if answer.downcase == 'y'
  end

  def play_round
    human.choose
    computer.choose
    puts "-----------------------------"
    display_moves
    display_round_winner
    display_scores
    puts "-----------------------------"
  end

  def play
    display_welcome_message
    loop do
      computer.score = 0
      human.score    = 0
      play_round until human.score == 3 || computer.score == 3
      display_overall_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
