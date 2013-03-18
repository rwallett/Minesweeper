class Minesweeper
  def initialize
    @board = make_board(:small)
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

  def display_board
    display_board = []
    @board.dup.each do |row|
      row.map! do |el|
        if el == "m"
          el = "_"
        else
          el = "_"
        end
      end
      display_board << row
    end
    display_board.each { |row| p row}
  end




end

mine = Minesweeper.new
mine.display_board