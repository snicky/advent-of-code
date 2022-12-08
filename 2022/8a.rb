Tree = Struct.new(:height, :visible)

class VisibleTreesCounter
  def initialize(grid)
    @grid = grid
  end

  def execute
    analyze!
    3.times do
      @grid = grid.transpose.map(&:reverse)
      analyze!
    end
    count_visible
  end

  private
  
  attr_reader :grid

  def analyze!
    grid[0].each { |tree| tree.visible = true }
    maxes = grid[0].map(&:height)

    grid[1..-2].each do |row|
      (1..row.size-2).each do |i|
        tree = row[i]

        if tree.height > maxes[i]
          tree.visible = true
          maxes[i] = tree.height
        end
      end
    end
  end

  def count_visible
    count = 0
    grid.each do |row|
      row.each do |tree|
        count += 1 if tree.visible
      end
    end
    count
  end
end

grid = File.
  read("input8").
  split("\n").
  map do |str|
    str.chars.map { |char| Tree.new(char.to_i, false) }
  end; 1

VisibleTreesCounter.new(grid).execute