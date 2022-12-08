Tree = Struct.new(:height, :counters)

class MaxScenicScoreFinder
  def initialize(grid)
    @grid = grid
  end

  def execute
    analyze!(0)
    3.times do |i|
      @grid = grid.transpose.map(&:reverse)
      analyze!(i+1)
    end
    find_max_score
  end

  private

  attr_reader :grid

  def analyze!(step)
    grid[0].each { |tree| tree.counters[step] = 0 }
    i = 1
    while i < grid.size
      row = grid[i]
      row.each_with_index do |tree, j|
        k = i - 1
        tree.counters[step] = 1
        prev_tree = grid[k][j]
        while k >= 1 && tree.height > prev_tree.height
          tree.counters[step] += 1
          k -= 1
          prev_tree = grid[k][j]
        end
      end
      i += 1
    end
  end

  def find_max_score
    max = 0
    grid.each do |row|
      row.each do |tree|
        scenic_score = tree.counters.reduce(:*)
        max = scenic_score if scenic_score > max
      end
    end
    max
  end
end

grid = File.
  read("input8").
  split("\n").
  map do |str|
    str.chars.map { |char| Tree.new(char.to_i, []) }
  end; 1

MaxScenicScoreFinder.new(grid).execute

