class ShortestPathFinder
  S = "S"
  E = "E"

  def initialize(heightmap)
    @heightmap = heightmap
    @last_row_index = heightmap.size - 1
    @last_col_index = heightmap[0].size - 1
    @start_pos = find_pos(S)
    @end_pos = find_pos(E)
    @visited = {}
    @scores = [S] + ("a".."z").to_a + [E]
  end

  def execute
    traverse!
    @visited[end_pos]
  end

  private

  attr_reader :heightmap,
              :last_col_index,
              :last_row_index,
              :visited,
              :start_pos,
              :end_pos,
              :scores

  def find_pos(elem)
    (0...heightmap.size).each do |i|
      row = heightmap[i]
      (0...row.size).each do |j|
        e = row[j]
        return [i, j] if e == elem
      end
    end
  end

  def traverse!
    queue = [start_pos]
    step = 0
    until visited[end_pos]
      queue.each do |pos|
        visited[pos] = step
      end
      next_queue = queue.flat_map do |pos|
        adjacent_visitable_positions(pos)
      end.uniq
      queue = next_queue
      step += 1
    end
  end

  def adjacent_visitable_positions(pos)
    row, col = pos
    score = heightmap[row][col]
    [
      ([row-1, col] if row > 0),
      ([row, col-1] if col > 0),
      ([row+1, col] if row < last_row_index),
      ([row, col+1] if col < last_col_index)
    ].compact.reject do |p|
      visited[p] || (
        r, c = p
        s = heightmap[r][c]
        scores.index(s) > scores.index(score) + 1
      )
    end
  end
end

heightmap = File.read("input12").split("\n").map(&:chars); 1
puts ShortestPathFinder.new(heightmap).execute