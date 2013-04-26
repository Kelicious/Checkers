require_relative 'board'
require_relative 'piece'
require_relative 'player'

class Checkers
  def initialize
    @board = Board.new
    @b = HumanPlayer.new(:b)
    @w = HumanPlayer.new(:w)
  end

  def greeting
    puts "Welcome to checkers!!"
  end

  def end_game
    puts "Placeholder"
  end

  def play
    greeting

    while true
      [@w, @b].each do |player|
        play_turn(player)
      end
    end

    end_game
  end

  def play_turn(player)
    @board.display
    color = player.color == :w ? "White" : "Black"
    puts "#{color} player's turn"
    
    while true
      move_sequence = player.attempt_move.map do |pos|
        Board.pos_to_coords(pos)
      end
    end

  end

  def valid_move_seq?(move_sequence)

  end
end
