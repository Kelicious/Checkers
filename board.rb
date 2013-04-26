require_relative 'piece'

class Board
  SIZE = 8

  def self.on_board?(coords)
    coords.all? {|coord| coord.between?(0, SIZE - 1)}
  end

  def self.pos_to_coords(pos)
    letter, number = pos.split("")
    # unless letter.between?('a', 'z') && number.between?(1, SIZE)
    #   raise ArgumentError.new("Invalid argument #{pos}")
    # end
    col, row = letter.ord - 'a'.ord, SIZE - number.to_i
    [row, col]
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
      return nil
      #raise ArgumentError.new("No halfway point available")
    end

    old_coords.zip(diffs).map {|old, diff| old + diff / 2}
  end

  def initialize
    @grid = Array.new(8) {Array.new(8, nil)}
    [:w, :b].each {|color| setup_pieces(color)}
  end

  def display
    first_row = "  a b c d e f g h"
    result = [first_row]
    SIZE.times {|i| result << display_row(i)}
    puts result
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

  def piece_at(pos)
    
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
    new_board.clear!
    (0...SIZE).each do |row|
      (0...SIZE).each do |col|
        previous_content = @grid[row][col]
        next if previous_content.nil?
        new_piece = previous_content.dup
        new_piece.board = new_board
        new_board.add_piece(new_piece, [row,col])
      end
    end

    new_board
  end

  def clear!
    @grid = Array.new(8) {Array.new(8, nil)}
  end

  private

  def self.dark_square?(coords)
    row, col = coords
    (row + col) % 2 != 0
  end

  def display_row(i)
    row = (SIZE - i).to_s
    @grid[i].each {|sq| row << (sq.nil? ? "  " : " #{sq.rep}").rjust(2)}
    row
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
