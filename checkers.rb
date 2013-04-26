require 'debugger'
require_relative 'board'
require_relative 'piece'
require_relative 'player'

class Checkers
  attr_accessor :board

  def initialize
    @board = Board.new
    @b = Player.new(:b)
    @w = Player.new(:w)
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
      
      if valid_move_seq?(move_sequence)
        @board.get_piece(move_sequence.shift).perform_moves!(move_sequence)
        break
      end
    end
  end

  def valid_move_seq?(move_sequence)
    debugger
    begin
      board_copy = @board.dup
      piece = board_copy.get_piece(move_sequence.first)
      piece.perform_moves!(move_sequence[1..-1])
      true
    rescue StandardError => e
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
      false
    end
  end
end
