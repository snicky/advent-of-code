Point = Struct.new(:x, :y)

class StraightLine
  MARKER = "#"

  def initialize(p1, p2)
    @p1, @p2 = [p1, p2].sort_by { |p| [p.x, p.y] }
  end

  def mark(grid)
    if p1.x == p2.x
      (p1.y..p2.y).each { |y| grid[y][p1.x] = "#" }
    else
      (p1.x..p2.x).each { |x| grid[p1.y][x] = "#" }
    end
  end

  private

  attr_reader :p1, :p2
end

class Line
  def initialize(points)
    @points = points
  end

  def mark(grid)
    (1...points.size).each do |i|
      StraightLine.new(points[i-1], points[i]).mark(grid)
    end
  end

  private

  attr_reader :points
end

class Grid
  EMPTY_MARKER = "."
  SAND_MARKER = "o"
  START_POINT_X = 500
  SLEEP_TIME = 0

  class GridOverflow < StandardError; end

  def initialize(lines)
    @lines = lines
    # Fake infinite line, should be long enough.
    bottom_line_length = lines.flatten.max_by(&:x).x + START_POINT_X
    # The bottom line is 2 rows below the last one from the input.
    bottom_line_y = lines.flatten.max_by(&:y).y + 2
    @lines << [
      Point.new(0, bottom_line_y),
      Point.new(bottom_line_length + 1, bottom_line_y)
    ]
    @grid_x_size = lines.flatten.max_by(&:x).x + 1
    @grid_y_size = lines.flatten.max_by(&:y).y + 1
  end

  def execute(draw: false)
    @draw = draw
    @dropped = 0
    generate_empty_grid
    lines.each { |line| Line.new(line).mark(grid) }
    draw_grid
    begin
      while true do
        sleep
        drop_sand
        @dropped += 1
      end
    rescue GridOverflow
      @dropped
    end
  end
  
  private

  attr_reader :grid_x_size,
              :grid_y_size,
              :grid,
              :lines,
              :dropped,
              :draw

  def generate_empty_grid
    @grid = Array.new(grid_y_size) do
      Array.new(grid_x_size) { EMPTY_MARKER }
    end
  end

  def draw_grid
    if draw
      puts `clear`
      grid.each do |row|
        puts row.join
      end
      puts "", "Dropped: #{dropped}", ""
    end
  end

  def drop_sand
    p = start_point
    raise GridOverflow if start_point_occupied?
    mark_point(p, SAND_MARKER)
    draw_grid
    sleep
    keep_dropping(p)
  end

  def keep_dropping(p)
    sleep
    if grid[p.y+1]&.[](p.x) == EMPTY_MARKER
      mark_and_keep_dropping(p) do |point|
        point.y += 1
      end
    elsif grid[p.y+1]&.[](p.x-1) == EMPTY_MARKER
      mark_and_keep_dropping(p) do |point|
        point.x -= 1
        point.y += 1
      end
    elsif grid[p.y+1]&.[](p.x+1) == EMPTY_MARKER
      mark_and_keep_dropping(p) do |point|
        point.x += 1
        point.y += 1
      end
    end
  end

  def mark_and_keep_dropping(p)
    mark_point(p, EMPTY_MARKER)
    yield(p)
    raise_if_grid_overflow(p)
    mark_point(p, SAND_MARKER)
    draw_grid
    keep_dropping(p)
  end

  def raise_if_grid_overflow(p)
    if p == start_point ||
       [-1, grid_x_size].include?(p.x) ||
       p.y == grid_y_size-1
      
      raise GridOverflow.new(p)
    end
  end

  def start_point
    Point.new(START_POINT_X, 0)
  end

  def start_point_occupied?
    sp = start_point
    @grid[sp.y][sp.x] == SAND_MARKER
  end

  def mark_point(point, char)
    @grid[point.y][point.x] = char
  end

  def sleep
    super SLEEP_TIME
  end
end

lines = File.
  read("input14").
  split("\n").
  map do |line|
    line.split(" -> ").map do |coords|
      x, y = coords.split(",")
      Point.new(x.to_i, y.to_i)
    end
  end

puts Grid.new(lines).execute