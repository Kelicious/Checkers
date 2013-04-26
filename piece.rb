require_relative 'board'

class InvalidMoveError < StandardError
end

class Piece
  attr_accessor :coords, :color, :board
  attr_reader :king

  def initialize(color, king = false)
    @color = color
    @king = king
  end

  def rep
    result = "#{@color.to_s.upcase}#{king? ? "K":""}"
  end

  def promote
    @king = true
  end
  
  alias_method :king?, :king

  def perform_moves!(move_sequence)
    if !(move_sequence.is_a?(Array)) || !(move_sequence.first.is_a?(Array))
      raise ArgumentError.new("Invalid move sequence format")
    end

    if Board.half_point(coords, move_sequence.first)
      puts Board.half_point(coords, move_sequence.first)
      while new_coords = move_sequence.shift
        perform_jump(new_coords)
      end
    else
      perform_slide(move_sequence.first)
    end
  end

  def dup
    Piece.new(@color, king?)
  end

  private

  def perform_slide(new_coords)
    if !(Board.on_board?(new_coords))
      raise InvalidMoveError.new("Slid off the board")
    elsif !(@board.empty_square?(new_coords))
      test = "#{coords.to_s} to #{new_coords.to_s}"
      test += @board.get_piece(new_coords).class.to_s
      puts @board.display
      raise InvalidMoveError.new("Slid onto a piece" + test)
    elsif !(slides.include?(new_coords))
      raise InvalidMoveError.new("Slid to an invalid location")
    end
    @board.add_piece(@board.remove_piece(coords), new_coords)
  end

  def perform_jump(new_coords)
    if !(Board.on_board?(new_coords))
      raise InvalidMoveError.new("Jumped off the board")
    elsif !(@board.empty_square?(new_coords))
      raise InvalidMoveError.new("Jumped onto a piece")
    elsif !(jumps.include?(new_coords))
      raise InvalidMoveError.new("Jumped to an invalid location")
    else
      jumped_coords = Board.half_point(coords, new_coords)
      jumped_content = @board.get_piece(jumped_coords)
      if jumped_content.nil?
        raise InvalidMoveError.new("Jumped over an empty square")
      elsif jumped_content.color == color
        raise InvalidMoveError.new("Jumped over own piece")
      end
      @board.add_piece(@board.remove_piece(coords), new_coords)
      @board.remove_piece(jumped_coords)
    end
  end
  
  def slides
    diagonals.map {|drow, dcol| [cur_row + drow, cur_col + dcol]}
  end

  def jumps
    diagonals.map {|drow, dcol| [cur_row + 2 * drow, cur_col + 2 * dcol]}
  end

  def diagonals
    directions = king? ? [direction, -direction] : [direction]
    
    directions.map {|dir| [[dir, 1], [dir, -1]]}.flatten(1)
  end
  
  def direction
    color == :b ? 1 : -1
  end

  def cur_row
    self.coords[0]
  end

  def cur_col
    self.coords[1]
  end
end
