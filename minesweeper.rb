#REV: Nicely done guys, just a few comments.
require 'debugger'
require 'yaml'

# To load saved game. Load minesweeper.rb in irb/pry.
# Then game = Minesweeper.load('save.yaml')
# Then game.play

class Minesweeper
  attr_reader :display_board, :board
  def initialize(size)
    @board = make_board(size) #REV: Is there some reason you guys have @board and @display_board? Can't you get @display_board from @board?
    @display_board = initial_display_board
    @history = []
    @start_time = Time.now #If you put start_time here and someone wants to load game, it includes the time from here until someone says they want to load game! Unfair!
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
    p "It took you: #{end_time - @start_time} seconds" #REV: Should save this somewhere for high scores list?
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
    neighbors = [[x-1 , y-1],[x-1 , y], [x-1 , y+1],
                      [x , y-1],[x,y],[x , y+1],
                      [x+1 , y-1], [x+1 , y],[x+1 , y+1]]
    neighbors.select! do |coord|
      # Find all possible moves from coordinates
      (coord[0] >= 0 && coord[0] <= 8)  && #REV: If you hard code 8 for your boundaries this won't work if your board is larger!
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


