require 'debugger'
require 'yaml'

# To load saved game. Load minesweeper.rb in irb/pry.
# Then game = Minesweeper.load('save.yaml')
# Then game.play

class Minesweeper
  attr_reader :display_board, :board
  def initialize(size)
    @board = make_board(size)
    @display_board = initial_display_board
    @history = []
    @start_time = Time.now
    play
  end

  def play
    forfeit = nil
    while game_won? == false && forfeit == nil
      puts "Here is the minefield:\n"
      @display_board.each{|row| p row}
      puts ''

      puts "Would you like to dig or flag? 1-Dig, 2-Flag, 3-Save, 4-Quit"
      command = gets.chomp.to_i
      case command
        when 3 then save_game
          # REV: you could do `when 4 return forfeit = "quit" `
        when 4
          forfeit = "quit"
          return
      end
      puts "Where would you like to dig/flag? x,y"
      coords = gets.chomp
      if command == 1 && is_mine?(coords[0].to_i, coords[2].to_i)
        p "You lose, Shame"
        return
      else
        case command
        when 1 then reveal(coords[0].to_i, coords[2].to_i)
        when 2 then flag(coords[0].to_i, coords[2].to_i)
        end
      end
    end
    p "Congrats you cleared the minefield."
    end_time = Time.now
    p "It took you: #{end_time - @start_time} seconds"
  end


  def save_game
    File.open("save.yaml", "w") do |f|
      f.puts self.to_yaml
    end
    puts "Game saved."
  end

  def Minesweeper.load(file_name)
    File.open(file_name, "r"){ |file| YAML.load(file)}
    p "Run .play to continue this game"
  end


  def make_board(size)
    board = []
    if size == :small
      row = []
      9.times {row << "_"}
      9.times {board << row.dup}
      # REV: this may reassign 'm' to a spot that already has 'm'
      # to guarantee 10 mines placed, do something like:
      # mines = 10
      # until mines == 0
      #   placement = board[rand(16)][rand(16)]
      #   if placement != 'm'
      #     board[rand(16)][rand(16)] = 'm'
      #     mines -= 1
      #   end
      # end
      10.times {board[rand(9)][rand(9)] = "m"}
    elsif size == :large
      16.times {row << "_"}
      16.times {board << row.dup}
      40.times {board[rand(16)][rand(16)] = "m"}
    end
    board
  end

  def initial_display_board
    display_board = []
    # REV: instead of deep_dup, a great one line method to make a board, then
    # another board, is `board = Array.new(9) { Array.new(9) { '_' } }
    @board.deep_dup.each do |row|
      row.map! do |el|
        if el == "m"
          el = "_"
        else
          el = "_"
        end
      end
      display_board << row
    end
    #p @board.each {|row| p row}
    display_board
  end

  def game_won?
    @display_board.each do |row|
      return false if row.include?("_")
    end
    true
  end

  def is_mine?(x,y)
    if @board[x][y] == "m"
      return true
    end
  end

  def get_neighbors(x,y)
    # REV: you could just do two nested loops:
    # (x-1..x+1).each do
    #   (y-1..y+1).each do
    #     ....
    neighbors = [[x-1 , y-1],[x-1 , y], [x-1 , y+1],
                      [x , y-1],[x,y],[x , y+1],
                      [x+1 , y-1], [x+1 , y],[x+1 , y+1]]
    neighbors.select! do |coord|
      # Find all possible moves from coordinates
      (coord[0] >= 0 && coord[0] <= 8)  &&
      (coord[1] >= 0 && coord[1] <= 8)
    end
    neighbors
  end

  def reveal(x,y)
    neighbors = get_neighbors(x,y)
    if count_mines(neighbors) != 0
      @display_board[x][y] = count_mines(neighbors).to_s unless              @board[x][y] == "m"
    else
      @display_board[x][y] = "X" unless @board[x][y] == "m"
      neighbors.each do |neighbor|
        next if @history.include?(neighbor)
        @history << neighbor
        reveal(neighbor[0], neighbor[1])
      end
    end
  end

  def count_mines(neighbors)
    mine_count = 0
    #debugger
    neighbors.each do |coord|
      mine_count += 1 if @board[coord[0]][coord[1]] == "m"
    end
    mine_count
  end

  def flag(x,y)
    @display_board[x][y] = "F"
  end

end

class Array
  def deep_dup
    # THANKS, NED!
    new_array = []
    self.each do |el|
      if el.is_a?(Array)
        new_array << el.deep_dup
      else
        new_array << el
      end
    end

    new_array
  end
end

mine = Minesweeper.new(:small)


