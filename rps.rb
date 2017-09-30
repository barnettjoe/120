require 'pry'

class Move
  def to_s
    self.class.name
  end
end

class Rock < Move
  def wins_against(opponent)
    case opponent
    when "Scissors" then "crushes"
    when "Lizard"   then "crushes"
    else
      false
    end
  end
end

class Paper < Move
  def wins_against(opponent)
    case opponent
    when "Rock"  then "covers"
    when "Spock" then "disproves"
    else
      false
    end
  end
end

class Scissors < Move
  def wins_against(opponent)
    case opponent
    when "Paper"  then "cuts"
    when "Lizard" then "decapitates"
    else
      false
    end
  end
end

class Lizard < Move
  def wins_against(opponent)
    case opponent
    when "Spock" then "poisons"
    when "Paper" then "eats"
    else
      false
    end
  end
end

class Spock < Move
  def wins_against(opponent)
    case opponent
    when "Scissors" then "smashes"
    when "Rock"     then "vaporizes"
    else
      false
    end
  end
end

class Player
  attr_accessor :move, :name, :score, :history, :opponent

  def initialize
    set_name
    @score = 0
    @history = []
    @opponent = nil
  end

  def win_round
    self.score += 1
  end

  def record(info)
    history << info
  end
end

class Human < Player
  def choose
    loop do
      puts "Please choose rock, paper, scissors, lizard, or spock:"
      choice = gets.chomp.capitalize
      if RPSGame::POSSIBLE_MOVES.include?(choice)
        self.move = Move.const_get(choice).new
        record choice
        break
      else
        puts "Sorry, invalid choice."
      end
    end
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
  attr_accessor :probs, :opponent

  def initialize
    super
    @probs = { "Rock"     => 1,
               "Paper"    => 1,
               "Scissors" => 1,
               "Lizard"   => 1,
               "Spock"    => 1 }
  end

  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def historical_chance_losing(move)
    times_played = history.each_slice(2).count { |slice| slice.first == move }
    times_lost = history.each_slice(2).count do |slice|
      slice.first == move && slice.last == opponent.name
    end
    chance = times_lost.fdiv times_played
    chance.nan? ? 1.0 : chance
  end

  def basic_choose
    RPSGame::POSSIBLE_MOVES.sample
  end

  def clever_choose
    # normal chance of losing is 0.4
    # normal chance of winning is 0.4
    # normal chance of tie is 0.2
    adjust_probabilities()
    # need to normalize so sum is 1
    normalized = probs.values.map { |x| x.fdiv probs.values.reduce(:+) }
    options = RPSGame::POSSIBLE_MOVES.zip(normalized).to_h
    # convert to cumulative probability
    acc = 0
    options.each { |e, w| options[e] = acc += w }
    # to select an element, pick a random between 0 and 1 and find the first
    # cummulative probability that's greater than the random number
    r = rand
    options.find { |_, w| w > r }.first
  end

  def adjust_probabilities
    RPSGame::POSSIBLE_MOVES.each do |move|
      if historical_chance_losing(move) > 0.5
        probs[move] = 0.5 / historical_chance_losing(move)
      end
    end
  end

  def choose
    choice =
      if RPSGame::POSSIBLE_MOVES.all? { |move| history.count(move) > 1 }
        clever_choose
      else
        basic_choose
      end
    self.move = Move.const_get(choice).new
    record choice
  end
end

class RPSGame
  POSSIBLE_MOVES = %w[Rock Paper Scissors Lizard Spock]
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
    human.opponent = computer
    computer.opponent = human
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
    puts "The first to get 3 points wins."
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def display_round_winner
    if computer.move.to_s == human.move.to_s
      tie()
    else
      winning_player = winner()
      losing_player  = loser()
      display_action(winning_player, losing_player)
      puts "#{winning_player.name} won the round!"
      winning_player.win_round
      record_winner(winning_player)
    end
  end

  def record_winner(winning_player)
    [human, computer].each { |player| player.record winning_player.name }
  end

  def tie
    puts "This round is a tie."
    [human, computer].each { |player| player.record "tie" }
  end

  def display_action(winning_player, losing_player)
    action = winning_player.move.wins_against(losing_player.move.to_s)
    puts "#{winning_player.move} #{action} #{losing_player.move}"
  end

  def winner
    human.move.wins_against(computer.move.to_s) ? human : computer
  end

  def loser
    # whoever is not the winner, must be the loser
    # (we only use this method we have already checked for a tie)
    [human, computer].find { |player| player != winner }
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
