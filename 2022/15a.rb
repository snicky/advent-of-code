Point = Struct.new(:x, :y)
class Point
  def distance_to(another)
    (x - another.x).abs + (y - another.y).abs
  end
end
class Beacon < Point; end
HorizontalLine = Struct.new(:x1, :x2)
class HorizontalLine
  def cells
    return 0 if x1 == x2

    x2 - x1 + 1
  end
end
class LineMerger
  def initialize(lines)
    @lines = lines.sort_by!(&:x1)
  end

  def execute
    merged = []
    prev_line = lines[0]
    cur_x1, cur_x2 = prev_line.x1, prev_line.x2
    lines.each_with_index do |line, index|
      next if index == 0

      if line.x1 > cur_x2
        merged << HorizontalLine.new(cur_x1, cur_x2)
        cur_x1, cur_x2 = line.x1, line.x2
      elsif line.x2 > cur_x2
        cur_x2 = line.x2
      end
    end
    merged << HorizontalLine.new(cur_x1, cur_x2)
  end

  private

  attr_reader :lines
end
class Sensor < Point
  attr_reader :beacon

  def initialize(x, y, beacon)
    @beacon = beacon
    super(x, y)
  end

  def coverage_on_row(row_num)
    distance_to_row_middle = (row_num - y).abs
    if distance_to_row_middle > distance_to_beacon
      nil
    else
      length_from_row_middle = (distance_to_beacon - distance_to_row_middle)
      HorizontalLine.new(
        x - length_from_row_middle,
        x + length_from_row_middle
      )
    end 
  end

  private

  def distance_to_beacon
    @distance_to_beacon = distance_to(beacon)
  end
end
class CoverageFinder
  def initialize(sensors, row_num)
    @sensors = sensors
    @row_num = row_num
    sensors.each do |sensor|
      @min_x = [@min_x, sensor.x, sensor.beacon.x].compact.min
      @max_x = [@max_x, sensor.x, sensor.beacon.x].compact.max
      @min_y = [@min_y, sensor.y, sensor.beacon.y].compact.min
      @max_y = [@max_y, sensor.y, sensor.beacon.y].compact.max
    end
  end

  def execute
    covered_cells_in_row = LineMerger.
      new(coverage_lines).
      execute.
      map(&:cells).
      reduce(:+)
    covered_cells_in_row - beacons_in_row
  end

  private

  attr_reader :sensors, :row_num, :min_x, :max_x, :min_y, :max_y

  def coverage_lines
    other_sensors_within_range.map do |sensor|
      sensor.coverage_on_row(row_num)
    end.compact
  end

  def other_sensors_within_range
    sensors.select do |sensor|
      lookup_row_range.include?(sensor.y)
    end
  end

  def beacons_in_row
    sensors.map(&:beacon).select do |beacon|
      beacon.y == row_num
    end.uniq.size
  end

  def lookup_row_range
    @lookup_row_range ||= (
      [row_num - max_radius, min_y].max..[row_num + max_radius, max_y].min
    )
  end

  def max_radius
    @max_radius = begin
      horizontal_length = [min_x, max_x, 1].map(&:abs).reduce(:+)
      max_radius = (horizontal_length - 1) / 2
    end
  end
end

SENSOR_AND_BEACON_POSITIONS_REGEXP = /x=(-?\d+).*y=(-?\d+).*x=(-?\d+).*y=(-?\d+)/
sensors = File.read("input15").split("\n").reduce([]) do |memo, line|
  _, sx, sy, bx, by = line.
    match(SENSOR_AND_BEACON_POSITIONS_REGEXP).
    to_a.
    map(&:to_i)
  memo << Sensor.new(sx, sy, Beacon.new(bx, by))
end

puts CoverageFinder.new(sensors, 2_000_000).execute
