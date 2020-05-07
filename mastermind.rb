=begin
The idea here is to create a new game.
Specifically I am aiming to create
Mastermind.  Where attempts are made
to guess the correct sequence of a
known bank of options.  Feedback will
be given to the user to play the game.

=end

#***Note this will run quite well
#***in Repl.it

#===================================#

class Game_Board

  attr_reader :num_places, :decode_gm_board, :disp_feedback, :slots, :rows

  attr_accessor :code

  def initialize(challenge_lvl)

    case challenge_lvl.to_i

    when 1

      @num_places = 6

      @rows = 10

      @slots = 3

    when 2

      @num_places = 6

      @rows = 10

      @slots = 4

    else

      @num_places = 7

      @rows = 12

      @slots = 5

    end

    @decode_gm_board = Array.new(@rows) {

      Array.new(@slots)

    }

    @disp_feedback = Array.new(@rows) {

      Array.new

    }

    @code = Array.new(@slots)

  end

end

#===================================#

class Cryptologist

  COLORS = {

    1 => :red,
    2 => :green,
    3 => :yellow,
    4 => :blue,
    5 => :pink,
    6 => :cyan,
    7 => :white

  }

  def initialize(gm_board)

    @gm_board = gm_board

    @@row_at = -1

    @@bl_match = {}

    @@wht_match = []

  end

  def disp_feedback

    #array copied to temp
    temp = @gm_board.code.dup

    @@bl_match = {}

    @@wht_match = []

    #check 1st correct color at position --> BLACK
    @gm_board.decode_gm_board[@@row_at].each_with_index do |i, index|

      if @gm_board.code[index] == i

        temp[index] = 0

        @gm_board.disp_feedback[@@row_at] << "BLACK"

        @@bl_match[index] = i

      end

    end

    #check correct color different position --> WHITE

    @gm_board.decode_gm_board[@@row_at].each_with_index do |i, index|

      if @gm_board.code[index] != i

        if temp.include?(i)

          @gm_board.disp_feedback[@@row_at] << "WHITE"

          temp.delete_at(temp.index(i))

          @@wht_match << i

        end

      end

    end
    #moving to next chance
    @@row_at += 1

  end

  def disp_code

    print "Code: "

    @gm_board.code.each do |val|

      print "  ".color(val) + "  "

    end

    puts ""

  end

  def disp_gm_board

    puts ""

    puts " |BLACK| means correct color in the correct space."

    puts " |WHITE| means correct color in the incorrect space."

    puts ""

    puts ""

    line = "        " + "---" * @gm_board.slots

    puts line

    gm_board_size = @gm_board.decode_gm_board.size - 1

    gm_board_size.downto(0) do |i|

      print "%7s "%"#{i + 1}. "

      @gm_board.slots.times do |k|

        print k.nil? ? "|  |" : "|" + "  ".color(@gm_board.decode_gm_board[i][k]) + "|"

      end

      print "  "

      @gm_board.disp_feedback[i].each do |k|

        print "|#{k}|"

      end

      print "\n"

      puts line

    end

    puts ""

  end

  def gm_finished?

    if @gm_board.decode_gm_board[@@row_at] == @gm_board.code

      disp_gm_board

      puts "CRACKED - You Win"

      true

    elsif @@row_at == @gm_board.rows - 1

      disp_gm_board

      puts "FAILED - You Lose, try again."

      true

    else

      false

    end

  end

end

#===================================#

class MasterMind

  def initialize(gm_board, player_cryptologist)

    @gm_board = gm_board

    if player_cryptologist

      @cryptologist = Player.new(gm_board)

      @codebreaker = AI.new(gm_board)

    else

      @cryptologist = AI.new(gm_board)

      @codebreaker = Player.new(gm_board)

    end

  end

  def begin

    @cryptologist.create_code

    while !gm_finished?

      @cryptologist.disp_gm_board

      @codebreaker.begin

    end

    puts ""

    @cryptologist.disp_code

    puts ""

  end

  private

    def gm_finished?

      if @codebreaker.gm_finished?

        true

      else

        @cryptologist.disp_feedback

        false

      end

    end

  end

#===================================#

class Player < Cryptologist

  def create_code

    puts "Please enter #{@gm_board.slots} colors separating them by a comma."

    disp_colors

    input_colors = get_valid_input

    @gm_board.slots.times do |i|

      @gm_board.code[i] = COLORS[input_colors[i]]

    end

    system "clear"

    system "clear"

  end

  def begin

    puts "Please choose up to #{@gm_board.slots} colors from 1 to #{@gm_board.num_places} separating each of them by a comma."

    disp_colors

    input_colors = get_valid_input

    input_colors.each_with_index do |i, index|

      input_colors[index] = COLORS[i]

    end

    @gm_board.decode_gm_board[@@row_at] = input_colors

  end

  private

    def disp_colors

      1.upto(@gm_board.num_places) do |i|

        print "#{i} = " + "  ".color(COLORS[i]) + "  "

      end

      print ": "

    end

    def get_valid_input

      input = gets.chomp

      while !valid_input?(input)

        print "Invalid input, try again..."

        input gets.chomp

      end

      input.split(",").map(&:to_i)

    end

    def valid_input?(input)

      begin

        input_a = input.split(",").map(&:to_i)

        if input_a.size > @gm_board.slots || !input_a.all? do |i|

            i <= @gm_board.num_places

          end

          return false

        else

          return true

        end

      rescue

        return false

      end

    end

  end

#===================================#

class String

  def colorize(color)

    "\e[#{color}m#{self}\e[0m"

  end

  def color(color)

    case color

    when :red

      colorize(41)

    when :green

      colorize(42)

    when :yellow

      colorize(43)

    when :blue

      colorize(44)

    when :pink

      colorize(45)

    when :cyan

      colorize(46)

    when :white

      colorize(47)

    else

      colorize(30)

    end

  end

end

#===================================#

class AI < Cryptologist

  def begin
    #feedback check BLACK
    if @@bl_match.size > 0

      @@bl_match.each do |key, val|

        @gm_board.decode_gm_board[@@row_at][key] = val

      end

    end

    #feedback check WHITE
    if @@wht_match.size > 0
      #assign to temp list
      temp = @@wht_match.size.times do |i|

        color = temp[rand(temp.size)]

        @gm_board.decode_gm_board[@@row_at][@gm_board.decode_gm_board[@@row_at].index(nil)] = color

        temp.slice!(temp.index(color))

      end

    end

    @gm_board.slots.times do |i|

      if @gm_board.decode_gm_board[@@row_at][i].nil?

        @gm_board.decode_gm_board[@@row_at][i] = COLORS[rand(1..@board.num_places)]

      end

    end

  end

  def create_code

    @gm_board.slots.times do |i|

      @gm_board.code[i] = COLORS[rand(1..@gm_board.num_places)]

    end

  end

end

#===================================#

puts "******************************************"
puts "******************************************"
puts "*******   Welcome to MasterMind!   *******"
puts "******************************************"
puts "******************************************"

puts "HOW TO PLAY MASTERMIND"

puts ""

sleep 0.5

puts "1 - You have to break a secret code in order to win the game."

sleep 0.5

puts ""

puts "2 - You have a given number of rounds to crack the code, depending on what challenge level you select.  In each round you will input what you think is the secret code."

puts ""

sleep 0.5

puts "3 - After submitting your code. The computer will try to help you to crack the code by giving hints as to correct colors, incorrect colors and correct colors that are in the incorrect position."

puts ""

sleep 0.5

puts "4 - The above is true, if you elect to create the code below, for the AI to guess."

puts ""

sleep 0.5

puts "Hint...this puzzle can be like History..."

sleep 2

puts ""

print "Please select the codemaker: 1. Computer  2. Human: "

player_cryptologist = gets.chomp

player_cryptologist = player_cryptologist == "1" ? false : true

print ""

print "Please select a challenge (1 - Easy, 2 - Medium, 3 - Hard): "

challenge_lvl = gets.chomp

puts ""



gm_board = Game_Board.new(challenge_lvl)

game = MasterMind.new(gm_board, player_cryptologist)

game.begin
