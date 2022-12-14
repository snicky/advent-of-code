input = File.
  read("input13").
  gsub('[]', '[0]').
  split("\n").
  reject(&:empty?).
  map { |str| eval(str).flatten }

divider1 = [2]
divider2 = [6]
input << divider1
input << divider2
input.sort!

puts (input.index(divider1) + 1) * 
     (input.index(divider2) + 1)
