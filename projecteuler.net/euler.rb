#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'

# Brute force recursive - 3m.
# This is a customised version of Integer#groupings
# There must be a better way.
# 190569291
def problem_76
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

# Brute force again - 4min
# There must be a better way.
def problem_77
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

def problem_77b
  primes = Primes.upto(120)

  (2..100).each do |num|
    off = primes.index {|i| i > num }
    off -= 1
    puts "#{num} => #{primes[off]}"
  end
end

if __FILE__ == $0
  p problem_77
end

