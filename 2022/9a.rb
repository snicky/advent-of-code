Coords = Struct.new(:x, :y)

class VisitedTailPositionsFinder
  def initialize(commands)
    @commands = commands
    @h = Coords.new(0, 0)
    @t = Coords.new(0, 0)
    @t_visited = Hash.new
    t_visited[[t.x, t.y]] = true
  end

  def execute
    commands.each { |c| execute_command(c) }
    count_t_visited
  end

  private

  attr_reader :commands, :h, :t, :t_visited

  def count_t_visited
    t_visited.size
  end

  def execute_command(command)
    direction, length = command.split(" ")
    length = length.to_i
    case direction
    when "U"
      go(length) { h.y -= 1 }
    when "R"
      go(length) { h.x += 1 }
    when "D"
      go(length) { h.y += 1 }
    when "L"
      go(length) { h.x -= 1 }
    end
  end

  def go(length)
    length.times do
      yield
      move_t unless t_adjacent?
    end
  end

  def move_t
    move_t_x
    move_t_y
    mark_t_visited
  end

  def move_t_x
    if h.x > t.x
      t.x += 1
    elsif h.x < t.x
      t.x -= 1
    end
  end

  def move_t_y
    if h.y > t.y
      t.y += 1
    elsif h.y < t.y
      t.y -= 1
    end
  end

  def mark_t_visited
    @t_visited[[t.x, t.y]] = true
  end

  def t_adjacent?
    (h.x-1..h.x+1).include?(t.x) && (h.y-1..h.y+1).include?(t.y)
  end
end

commands = File.read("input9").split("\n"); 1
VisitedTailPositionsFinder.new(commands).execute
