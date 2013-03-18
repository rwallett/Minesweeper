require 'debugger'

class Minesweeper
  attr_reader :display_board, :board
  def initialize
    @board = make_board(:small)
    @display_board = initial_display_board
    @history = []
  end

  def make_board(size)
    small_board = []
    if size == :small
      row = []
      9.times {row << "_"}
      9.times {small_board << row.dup}
      small_board
    end
    10.times {small_board[rand(9)][rand(9)] = "m"}
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
    p @board.each {|row| p row}
    display_board
  end

  def game_won?
    @board.each do |row|
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
                      [y , x-1],[y , x+1],
                      [y+1 , x-1], [y+1 , x],[y+1 , x+1]]
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
      @display_board[y][x] = count_mines(neighbors).to_s
    else
      neighbors.each do |neighbor|
        next if @history.include?(neighbor)
        @history << neighbor
        reveal(neighbor[0], neighbor[1])
      end
    end
    return [x,y,count_mines(neighbors)]
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
mine.reveal(3,4)
p mine.display_board.each {|row| p row}
p mine.board[4][4]

