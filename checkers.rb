class Board
  SIZE = 8

  # Remember to make grid private later!!!
  attr_accessor :grid

  def self.on_board?(coords)
    coords.all? {|coord| coord.between?(0, SIZE - 1)}
  end

  def self.pos_to_coords(pos)
    letter, number = pos.split("")
    y = letter.ord - 'a'.ord
    x = 8 - number.to_i
    [x, y]
  end

  def self.coords_to_pos(coords)
    x, y = coords
    letter = (y.ord + 'a'.ord).chr
    number = 8 - x
    "#{letter}#{number}"
  end

  def self.half_point(old_coords, new_coords)
    diffs = new_coords.zip(old_coords).map {|new, old| new - old}
    if (diffs.any? {|diff| diff % 2 != 0})
      raise ArgumentError.new("No halfway point available")
    end

    old_coords.zip(diffs).map {|old, diff| old + diff / 2}
  end

  def initialize
    @grid = Array.new(8) {Array.new(8, nil)}
    [:w, :b].each {|color| setup_pieces(color)}
  end

  def add_piece(piece, coords)
    row, col = coords
    piece.coords = coords
    piece.board = self
    @grid[row][col] = piece
  end

  def remove_piece(coords)
    row, col = coords
    old_content, @grid[row][col] = @grid[row][col], nil
    old_content
  end

  def get_piece(coords)
    row, col = coords
    @grid[row][col]
  end

  def empty_square?(coords)
    get_piece(coords).nil?
  end
  
  def dup
    new_board = Board.new
    (0...SIZE).each do |row|
      (0...SIZE).each do |col|
        item = @grid[row][col]
        new_board.add_piece(item.dup, [row,col]) if item
      end
    end

    new_board
  end

  private

  def self.dark_square?(coords)
    row, col = coords
    (row + col) % 2 != 0
  end

  def setup_pieces(color)
    rows = color == :b ? (0..2) : (5..7)
    rows.each do |row|
      (0...SIZE).each do |col|
        coords = [row, col]
        add_piece(Piece.new(color), coords) if Board.dark_square?(coords)
      end
    end
  end
end

class InvalidMoveError < StandardError
end

class Piece
  attr_accessor :coords, :color, :board, :king

  def initialize(color, king = false)
    @color = color
    @king = king
  end
  
  alias_method :king?, :king

  def perform_moves!(move_sequence)
    if !(move_sequence.is_a?(Array)) || !(move_sequence.first.is_a?(Array))
      raise ArgumentError.new("Invalid move sequence")
    end

    case move_sequence.length
    when 1
      perform_slide(move_sequence.first)
    else
      while new_coords = move_sequence.shift
        perform_jump(new_coords)
      end
    end
  end

  private

  def perform_slide(new_coords)
    if !(Board.on_board?(new_coords))
      raise InvalidMoveError.new("Slid off the board")
    elsif !(board.empty_square?(new_coords))
      raise InvalidMoveError.new("Slid onto a piece")
    elsif !(slides.include?(new_coords))
      raise InvalidMoveError.new("Slid to an invalid location")
    end

    @board.add_piece(@board.remove_piece(coords), new_coords)
  end

  def perform_jump(new_coords)
    if !(Board.on_board?(new_coords))
      raise InvalidMoveError.new("Jumped off the board")
    elsif !(board.empty_square?(new_coords))
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

    raise "This should never be thrown"
  end
  
  def slides
    diagonals.map {|drow, dcol| [cur_row + drow, cur_col + dcol]}
  end

  def jumps
    diagonals.map {|drow, dcol| [cur_row + 2 * drow, cur_col + 2 * dcol]}
  end

  def diagonals
    directions = king? ? [direction] : [direction, -direction]
    
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

  def dup
    Piece.new(@color, king?)
  end
end
