Point = Struct.new(:x, :y)
class Point
  def distance_to(another)
    (x - another.x).abs + (y - another.y).abs
  end
end
class Sensor < Point
  attr_reader :beacon

  def initialize(x, y, beacon)
    @beacon = beacon
    super(x, y)
  end

  def coverage_on_row(row_num)
    if (row_num - y).abs > distance_to(beacon)
      nil
    else
      "..."
    end 
  end
end
class Beacon < Point; end

SENSOR_AND_BEACON_POSITIONS_REGEXP = /x=(-?\d+).*y=(-?\d+).*x=(-?\d+).*y=(-?\d+)/
sensors = File.read("input15").split("\n").reduce([]) do |memo, line|
  _, sx, sy, bx, by = line.
    match(SENSOR_AND_BEACON_POSITIONS_REGEXP).
    to_a.
    map(&:to_i)
  memo << Sensor.new(sx, sy, Beacon.new(bx, by))
end

min_x = nil
max_x = nil
sensors.reduce(nil) do |memo, sensor|
  min_x = [min_x, sensor.x, sensor.beacon.x].compact.min
  max_x = [max_x, sensor.x, sensor.beacon.x].compact.max
end
horizontal_length = [min_x, max_x, 1].map(&:abs).reduce(:+)
max_radius = (horizontal_length - 1) / 2