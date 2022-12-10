class SignalStrengthFinder
  def initialize(commands)
    @commands = commands
    @value = 1
    @cycle = 1
    @values_at_cycles = (20..220).step(40).to_a.map { |i| [i, 0] }.to_h
  end

  def execute
    commands.each { |c| execute_command(c) }
    reported_signal_strengths_sum
  end

  private

  attr_reader :commands, :value, :cycle, :values_at_cycles

  def execute_command(command)
    increment_and_report_cycle
    unless command == "noop"
      increment_and_report_cycle { @value += command.split(" ").last.to_i }
    end
  end

  def increment_and_report_cycle
    @cycle += 1
    yield if block_given?
    values_at_cycles[cycle] = value if values_at_cycles.include?(cycle)
  end

  def reported_signal_strengths_sum
    values_at_cycles.reduce(0) do |memo, (cycle, value)|
      memo += cycle * value
    end
  end
end

commands = File.read("input10").split("\n"); 1
SignalStrengthFinder.new(commands).execute
