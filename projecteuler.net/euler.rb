#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'

# Brute force recursive - 5m11s.
# This is a customised version of Integer#groupings
# There must be a better way.
# 190569291
def problem_76
  num = 100
  n = 0

  solve = lambda do |a,off,max|
    n = 0
    while a[off] < max && (a.length-off) >= 2   
      a[off] += a.pop
      n += 1
      n += solve.call(a.dup,off+1,a[off]) if a.length - off > 1
    end
    n
  end

  start = [1] * num
  1 + solve.call(start, 0, num-1)
end

if __FILE__ == $0
  p problem_76
end

