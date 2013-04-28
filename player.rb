class Player
  attr_accessor :color

  def initialize(color)
    @color = color
  end
# REV: I see that our Player classes are getting more and more minimal...
# REV: Not that it's a bad thing.
  def attempt_move
    puts "Please enter your move(e.g. c3 d4 for slide)"
    locs = gets.chomp.split(" ")
  end
end
