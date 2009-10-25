#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'

def problem_50
  primes = []
  Primes.each do |p|
    break if p >= 5000 # 4920 - last 21 terms sum > 1_000_000
    primes << p
  end
  max,max_p = 0,0
  reset = false
  top = 1
  bottom = 0
  sum = primes[bottom] + primes[top]
  sum_total = sum
  while top < primes.length do
    return(max_p) if sum > 1_100_000
    if sum.prime?
      tb = top-bottom+1
      if tb > max && sum < 1_000_000
        max,max_p = tb,sum
        puts "Prime #{sum} #{tb}"
      end
    else
      if bottom + 1 != top
        sum -= primes[bottom]
        bottom += 1
        next
      end
    end
    top += 1
    sum_total += primes[top]
    sum = sum_total
    bottom = 0
  end
end

def problem_67
  problem_18(open("triangle.txt").read.split(/\s+/).map(&:to_i))
end

if __FILE__ == $0
  p problem_50
end

