def right_order?(left, right)
  a, b = left.shift, right.shift
  return true unless a
  return false unless b

  case [a, b]
  in [Array, Array]
    if a.empty? && b.empty?
      right_order?(left, right)
    else
      right_order?(a, b)
    end
  in [Integer, Integer]
    if a == b
      right_order?(left, right)
    else
      a < b
    end
  else
    right_order?(Array(a), Array(b))
  end
end

output = File.
  read("input13").
  split("\n").
  reject(&:empty?).
  map { |str| eval(str) }.
  each_slice(2).
  each_with_index.
  reduce(0) do |memo, ((arr1, arr2), index)|
    memo + (right_order?(arr1, arr2) ? index + 1 : 0)
  end

puts output