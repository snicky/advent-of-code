require "prime"

class Monkey
  attr_reader :items_inspected

  PRIMES_LCM = Prime.first(8).reduce(:lcm)

  def initialize(
    items:,
    operation:,
    test_mod:,
    on_true:,
    on_false:,
    monkeys:
  )
    @items = items
    @operation = operation
    @test_mod = test_mod
    @on_true = on_true
    @on_false = on_false
    @items_inspected = 0
    @monkeys = monkeys
    @monkeys << self
  end

  def take_turn!
    items.each do |item|
      result = operation.call(item) % PRIMES_LCM
      next_monkey_index = if result % test_mod == 0
                            on_true
                          else
                            on_false
                          end
      next_monkey = monkeys[next_monkey_index]
      next_monkey.catch!(result)
      @items_inspected += 1
    end
    @items = []
  end

  def catch!(item)
    items << item
  end

  private

  attr_reader :items, :operation, :test_mod, :on_true, :on_false, :monkeys
end

class MonkeyBusinessCounter
  ROUNDS = 10_000

  def initialize(monkeys)
    @monkeys = monkeys
  end

  def count!
    ROUNDS.times { monkeys.each(&:take_turn!) }
    monkeys.map(&:items_inspected).max(2).reduce(:*)
  end

  private

  attr_reader :monkeys
end

# Hardcoded input.
monkeys = []
# Monkey 0:
#   Starting items: 63, 84, 80, 83, 84, 53, 88, 72
#   Operation: new = old * 11
#   Test: divisible by 13
#     If true: throw to monkey 4
#     If false: throw to monkey 7
Monkey.new(
  items: [63, 84, 80, 83, 84, 53, 88, 72],
  operation: ->(wl) { wl * 11 },
  test_mod: 13,
  on_true: 4,
  on_false: 7,
  monkeys: monkeys
)
# Monkey 1:
#   Starting items: 67, 56, 92, 88, 84
#   Operation: new = old + 4
#   Test: divisible by 11
#     If true: throw to monkey 5
#     If false: throw to monkey 3
Monkey.new(
  items: [67, 56, 92, 88, 84],
  operation: ->(wl) { wl + 4 },
  test_mod: 11,
  on_true: 5,
  on_false: 3,
  monkeys: monkeys
)
# Monkey 2:
#   Starting items: 52
#   Operation: new = old * old
#   Test: divisible by 2
#     If true: throw to monkey 3
#     If false: throw to monkey 1
Monkey.new(
  items: [52],
  operation: ->(wl) { wl * wl },
  test_mod: 2,
  on_true: 3,
  on_false: 1,
  monkeys: monkeys
)
# Monkey 3:
#   Starting items: 59, 53, 60, 92, 69, 72
#   Operation: new = old + 2
#   Test: divisible by 5
#     If true: throw to monkey 5
#     If false: throw to monkey 6
Monkey.new(
  items: [59, 53, 60, 92, 69, 72],
  operation: ->(wl) { wl + 2 },
  test_mod: 5,
  on_true: 5,
  on_false: 6,
  monkeys: monkeys
)
# Monkey 4:
#   Starting items: 61, 52, 55, 61
#   Operation: new = old + 3
#   Test: divisible by 7
#     If true: throw to monkey 7
#     If false: throw to monkey 2
Monkey.new(
  items: [61, 52, 55, 61],
  operation: ->(wl) { wl + 3 },
  test_mod: 7,
  on_true: 7,
  on_false: 2,
  monkeys: monkeys
)
# Monkey 5:
#   Starting items: 79, 53
#   Operation: new = old + 1
#   Test: divisible by 3
#     If true: throw to monkey 0
#     If false: throw to monkey 6
Monkey.new(
  items: [79, 53],
  operation: ->(wl) { wl + 1 },
  test_mod: 3,
  on_true: 0,
  on_false: 6,
  monkeys: monkeys
)
# Monkey 6:
#   Starting items: 59, 86, 67, 95, 92, 77, 91
#   Operation: new = old + 5
#   Test: divisible by 19
#     If true: throw to monkey 4
#     If false: throw to monkey 0
Monkey.new(
  items: [59, 86, 67, 95, 92, 77, 91],
  operation: ->(wl) { wl + 5 },
  test_mod: 19,
  on_true: 4,
  on_false: 0,
  monkeys: monkeys
)
# Monkey 7:
#   Starting items: 58, 83, 89
#   Operation: new = old * 19
#   Test: divisible by 17
#     If true: throw to monkey 2
#     If false: throw to monkey 1
Monkey.new(
  items: [58, 83, 89],
  operation: ->(wl) { wl * 19 },
  test_mod: 17,
  on_true: 2,
  on_false: 1,
  monkeys: monkeys
)

puts MonkeyBusinessCounter.new(monkeys).count!