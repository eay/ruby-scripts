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

# Tweaking of problem_81, to solve I work from the last column back.
# We create a new column which is the current value + the minium
# cost to the next column.  To work out this minium cost, we can
# move up/down an arbitary number then go right.
def problem_82
  grid = open("matrix.txt").each_line.to_a.map do |l|
    l.chomp.split(/,/).map(&:to_i)
  end.transpose

  # return a new row with the minimum values achievable
  # moving from x0 to x1
  right_min = lambda do |x0,x1|
    len = x0.length
    ret = []
    (0...len).each do |y|
      # For each y item we calcultate the possible scores of
      # moving up(n)/down(n) then right
      delta = []
      delta[y] = 0
      (y-1).downto(0).each do |yy|
        delta[yy] = delta[yy+1] + x0[yy]
      end
      (y+1).upto(len-1).each do |yy|
        delta[yy] = delta[yy-1] + x0[yy]
      end
      # delta is the up/down cost, now add the value of the right element
      delta.each_index do |i|
        delta[i] = delta[i] + x1[i]
      end
      # Delta now contains possible values to the next row, put the smallest
      # in the return spot
      ret[y] = x0[y] + delta.min
    end
    ret
  end

  # Start at the back and keep on generating new 'final' columns
  # # Start at the back and keep on generating new 'final' columns.
  last = right_min.call(grid[-2],grid[-1])
  (grid.length-3).downto(0).each do |x|
    last = right_min.call(grid[x],last)
  end
  last.min
end

def problem_83
  grid = open("matrix.txt").each_line.to_a.map do |l|
    l.chomp.split(/,/).map(&:to_i)
  end
  seen = {}

  # If we have 'used' a value, set it to nil in g.  We can go
  # up/down/left/righ, but we cannot use a value twice.  
  # We will also have to update seen if we hit a smaller value
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

# Arrggg... put the 'generate next value' ahead of the
# 'save current value if best'.
def problem_85(target = 2_000_000)
  # The logic
  num_rec_old = lambda do |x,y|
    n = 0
    (1..x).each do |xs|
      (1..y).each do |ys|
        m = (y - ys + 1) * (x - xs + 1)
        puts "#{x} #{y} => #{m}"
        n += m
      end
    end
    n
  end

  # The generator
  num_rec = lambda do |x,y|
    ((x+1)*x/2) * ((y+1)*y/2) # Triangle number
  end

  # Start at a mid-point larger than the target
  x,y,n = 1,200,0
  best = [target*2,0,x,y]
  while y >= 1
    n = num_rec.call(x,y)
    # Don't need to check for n == target, not possible
    if best[0] >= (n - target).abs
      puts "n=#{n} x=#{x} y=#{y}"
    end
    best = [best,[(n-target).abs,n,x,y]].min
    if n > target
      y -= 1
    else
      x += 1
    end
  end
  best[2] * best[3]
end

if __FILE__ == $0

  p problem_85
end

