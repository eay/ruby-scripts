#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'

# Brute force recursive - 3m.
# This is a customised version of Integer#groupings
# There must be a better way.
# 190569291
def problem_76a
  num = 100
  solve = lambda do |a,off,max|
    n = 0
    while a[off] < max && (a.length-off) >= 2   
      a[off] += a.pop
      n += 1
      n += solve.call(a.dup,off+1,a[off]) if a.length - off > 1
    end
    n
  end
  puts 1 + solve.call([1] * num, 0,num-1)
end

# 0.05 seconds, the secret is caching :-)
# For 100, we cache 4851 values
# http://mathworld.wolfram.com/PartitionFunctionP.html
def problem_76
  return 100.partitions - 1
end

# Brute force again - 4min
# There must be a better way.
def problem_77a
  primes = Primes.upto(100)

  # off is the offset in the prime array, we can work down :-)
  solve = lambda do |a,off,max|
    n = 0
    while a[off] < max && (a.length-off) >= 2   
      a[off] += a.pop
      n += 1 if (a & primes).length == a.uniq.length
      n += solve.call(a.dup,off+1,a[off]) if a.length - off > 1
    end
    n
  end
  m = 0
  (2..100).each do |num|
    break if (m = solve.call([1] * num,0,num-1)) > 5000
    puts "#{num} => #{m}"
  end
  m
end

# The fast version :-), 0.2sec
# I should look at
# http://mathworld.wolfram.com/EulerTransform.html
# Simplar problem to 31.  Need to work from the top down,
# for 76 to speed things up
def problem_77
  primes = Primes.upto(120)

  # num is the value we want and
  # off is the index in primes to use next
  hits = 0
  solve = lambda do |num, off|
    return 1 if num == 0
    return 0 if num == 1
    ret = 0
    p = primes[off]
    ret += 1 if num % p == 0 # Add if a multiple
    ret += solve.call(num,off-1) if off > 0 
    n = num / p
    if n > 0 # Do each multiple
      1.upto(n) do |i|
        left = num - i*p
        ret += solve.call(left,off-1) if off > 0 && left > 1
      end
    end
    ret
  end

  #(2..100).each do |num|
  num = 0
  (2..100).each do |num|
    off = primes.index {|i| i > num } - 1
    hits = solve.call(num,off)
    puts "#{num} => #{hits}"
    return num if hits >= 5000
  end
end

# hmm... ugly, needed the generator from
# http://en.wikipedia.org/wiki/Partition_(number_theory)
# runtime is about 6 sec.
# The trick is to cache the previous values so the sumation is quick.
# A bit of a weird generator function.
def problem_78
  n = 1
  p_cache = [1]

  generate = lambda do |k|
    ret = 0
    sign = 0
    Integer.generalized_pentagonals do |gp|
      if k < gp
        false # Need to exit ruby1.8, can't break...
      else
        if sign >= 0
          ret += p_cache[k-gp]
        else
          ret -= p_cache[k-gp]
        end
        sign += (sign == 1) ? -3 : 1 # 4 states + + - -
      end
    end
    p_cache[k] = ret % 100_000_000
    ret
  end

  p = 1
  loop do
    r =  generate.call(p)
#    puts "#{p} #{generate.call(p)}"
    break if r % 1_000_000 == 0
    p += 1
  end
  p
end

if __FILE__ == $0
  p problem_78
end

