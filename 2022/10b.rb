class CRT
  def initialize(commands)
    @commands = commands
    @value = 1
    @cycles = 1
    @values_at_cycles = {1 => 1}
  end

  def execute
    commands.each { |c| execute_command(c) }
    print_pixels
  end

  private

  attr_reader :commands, :value, :cycles, :values_at_cycles

  def execute_command(command)
    increment_and_report_cycle
    unless command == "noop"
      increment_and_report_cycle { @value += command.split(" ").last.to_i }
    end
  end

  def increment_and_report_cycle
    @cycles += 1
    yield if block_given?
    values_at_cycles[cycles] = value
  end

  def print_pixels
    (1..240).each_slice(40) do |cycles|
      lines = cycles.each_with_index.reduce("") do |memo, (cycle, index)|
        sprite_middle = values_at_cycles[cycle]
        sprite_position = (sprite_middle-1..sprite_middle+1)
        memo += (sprite_position.include?(index) ? "#" : ".")
      end
      puts lines
    end
  end
end

commands = File.read("input10").split("\n"); 1
CRT.new(commands).execute
