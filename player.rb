class Player
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def attempt_move
    puts "Please enter your move(e.g. c3 d4 for slide)"
    locs = gets.chomp.split(" ")
  end
end
