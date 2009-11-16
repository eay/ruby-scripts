#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'

# The recursive one, that saves intermediate values.
# We could implement this by working down to both ends then
# matching them.
def problem_81
  grid = open("matrix.txt").each_line.to_a.map do |l|
    l.chomp.split(/,/).map(&:to_i)
  end
  seen = {}

  walk = lambda do |g,x,y|
    # return seen values
    if s = seen["#{x} #{y}"]
      return s
    end

    # return nil unless we are on the grid 
    return nil unless g[y] && g[y][x]

    sum_r = walk.call(g,x+1,y)
    sum_d = walk.call(g,x,y+1)

    # Return the smallest value
    if sum_r && sum_d
      r = (sum_r < sum_d) ? sum_r : sum_d
    else
      r = sum_r || sum_d || 0
    end
    # cache
    seen["#{x} #{y}"] = r + g[y][x] 
  end

  walk.call(grid.dup,0,0)
end

if __FILE__ == $0
  p problem_81
end

