Coords = Struct.new(:x, :y)

class VisitedTailPositionsFinder
  def initialize(commands)
    @commands = commands
    @h = Coords.new(0, 0)
    @body = Array.new(9) { Coords.new(0,0) }
    @t_visited = Hash.new
    t_visited[[t.x, t.y]] = true
  end

  def execute
    commands.each { |c| execute_command(c) }
    count_t_visited
  end

  private

  attr_reader :commands, :h, :body, :t_visited

  def count_t_visited
    t_visited.size
  end

  def execute_command(command)
    direction, length = command.split(" ")
    length = length.to_i
    case direction
    when "U"
      go(length) { h[1] -= 1 }
    when "R"
      go(length) { h[0] += 1 }
    when "D"
      go(length) { h[1] += 1 }
    when "L"
      go(length) { h[0] -= 1 }
    end
  end

  def go(length)
    length.times do
      yield
      prev = h
      @body.each do |point|
        move_point(point, prev) unless adjacent?(point, prev)
        prev = point
      end
      mark_t_visited
    end
  end

  def move_point(this, prev)
    move_point_x(this, prev)
    move_point_y(this, prev)
  end

  def move_point_x(this, prev)
    if prev.x > this.x
      this.x += 1
    elsif prev.x < this.x
      this.x -= 1
    end
  end

  def move_point_y(this, prev)
    if prev.y > this.y
      this.y += 1
    elsif prev.y < this.y
      this.y -= 1
    end
  end

  def mark_t_visited
    @t_visited[[t.x, t.y]] = true
  end

  def t
    @t ||= body.last
  end

  def adjacent?(this, prev)
    (prev.x-1..prev.x+1).include?(this.x) &&
      (prev.y-1..prev.y+1).include?(this.y)
  end
end

commands = File.read("input9").split("\n"); 1
VisitedTailPositionsFinder.new(commands).execute
