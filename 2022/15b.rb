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

    (x1..x2).size
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
        [x - length_from_row_middle, grid_x_range.first].max,
        [x + length_from_row_middle, grid_x_range.last].min
      )
    end 
  end

  def grid_x_range=(range)
    @grid_x_range = range
  end

  private

  attr_reader :grid_x_range

  def distance_to_beacon
    @distance_to_beacon = distance_to(beacon)
  end
end
class CoverageFinder
  def initialize(sensors, row_num)
    @sensors = sensors
    @row_num = row_num
  end

  def execute(ignore_beacons: false)
    covered_cells_in_row = merged_coverage_lines.
      map(&:cells).
      reduce(:+)
    covered_cells_in_row -= beacons_in_row unless ignore_beacons
    covered_cells_in_row
  end

  def merged_coverage_lines
    @merged_coverage_lines ||= LineMerger.new(coverage_lines).execute
  end

  private

  attr_reader :sensors, :row_num

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
      [row_num - max_radius, $min_y].max..[row_num + max_radius, $max_y].min
    )
  end

  def max_radius
    @max_radius = begin
      horizontal_length = [$min_x, $max_x, 1].map(&:abs).reduce(:+)
      max_radius = (horizontal_length - 1) / 2
    end
  end
end

class DistressBeaconFinder
  def initialize(sensors, lookup_range)
    @sensors = sensors
    @lookup_range = lookup_range
  end

  def execute
    cf = nil
    lookup_range_size = lookup_range.size
    y = lookup_range.find do |row_num|
      puts row_num if row_num % 10_000 == 0
      cf = CoverageFinder.new(sensors, row_num)
      cf.execute(ignore_beacons: true) < lookup_range_size
    end
    # Assuming there's a single free point for the distress beacon
    # and thus only two lines to check.
    x = cf.merged_coverage_lines[0].x2 + 1
    [x, y]
  end

  private

  attr_reader :sensors, :lookup_range
end

SENSOR_AND_BEACON_POSITIONS_REGEXP = /x=(-?\d+).*y=(-?\d+).*x=(-?\d+).*y=(-?\d+)/
sensors = File.read("input15").split("\n").reduce([]) do |memo, line|
  _, sx, sy, bx, by = line.
    match(SENSOR_AND_BEACON_POSITIONS_REGEXP).
    to_a.
    map(&:to_i)
  memo << Sensor.new(sx, sy, Beacon.new(bx, by))
end
sensors.each do |sensor|
  $min_x = [$min_x, sensor.x, sensor.beacon.x].compact.min
  $max_x = [$max_x, sensor.x, sensor.beacon.x].compact.max
  $min_y = [$min_y, sensor.y, sensor.beacon.y].compact.min
  $max_y = [$max_y, sensor.y, sensor.beacon.y].compact.max
end
HARD_LOOKUP_RANGE = (0..4_000_000)
lookup_range = [HARD_LOOKUP_RANGE.first, $min_x].max..[HARD_LOOKUP_RANGE.last, $max_x].min
sensors.each do |sensor|
  sensor.grid_x_range = lookup_range
end

coords = DistressBeaconFinder.new(sensors, lookup_range).execute
puts (coords[0] * 4_000_000 + coords[1])