require 'debugger'

class Minesweeper
  attr_reader :display_board, :board
  def initialize
    @board = make_board(:small)
    @display_board = initial_display_board
    @history = []
    play
  end

  def play
    while game_won? == false
      puts "Here is the minefield:\n"
      @board.each {|row| p row}
      @display_board.each_with_index {|row, index| p index, row}
      puts ''
      puts "Would you like to dig or flag? 1-Dig, 2-Flag"
      command = gets.chomp.to_i
      puts "Where would you like to dig/flag? x,y"
      coords = gets.chomp
      if is_mine?(coords[0].to_i, coords[2].to_i)
        p "You lose, Shame"
        return
      else
        case command
        when 1 then reveal(coords[0].to_i, coords[2].to_i)
        when 2 then flag(coords[0].to_i, coords[2].to_i)
        end
      end
    end
    "Congrats you cleared the minefield."
  end

  def make_board(size)
    small_board = []
    if size == :small
      row = []
      9.times {row << "_"}
      9.times {small_board << row.dup}
      small_board
    end
    1.times {small_board[rand(9)][rand(9)] = "m"}
    small_board.each {|row| p row}
    small_board
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
    if @board[y][x] == "m"
      return true
    end
  end

  def get_neighbors(x,y)
    neighbors = [[y-1 , x-1],[y-1 , x], [y-1 , x+1],
                      [y , x-1],[y,x],[y , x+1],
                      [y+1 , x-1], [y+1 , x],[y+1 , x+1]]
    neighbors.select! do |coord|
      # Find all possible moves from coordinates
      (coord[0] >= 0 && coord[0] <= 8)  &&
      (coord[1] >= 0 && coord[1] <= 8)
    end
    neighbors
  end

  def reveal(x,y)
    neighbors = get_neighbors(y,x)
    if count_mines(neighbors) != 0
      @display_board[y][x] = count_mines(neighbors).to_s unless              @board[x][y] == "m"
    else
      @display_board[y][x] = "X" unless @board[y][x] == "m"
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
    @display_board[y][x] = "F"
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

mine = Minesweeper.new


