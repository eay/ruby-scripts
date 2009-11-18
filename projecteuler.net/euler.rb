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
  if false
    # Answer 2297
    grid = [
      [131, 673, 234, 103,  18],
      [201,  96, 342, 965, 150],
      [630, 803, 746, 422, 111],
      [537, 699, 497, 121, 956],
      [805, 732, 524,  37, 331]
    ]
    puts "Answer = #{2297}"
  else
    grid = open("matrix.txt").each_line.to_a.map do |l|
      l.chomp.split(/,/).map(&:to_i)
    end
#    grid = grid[0,10]
#    grid.map! {|a| a[0,10]}
    puts "Answer <= 427337"
  end
  # Seen will cache :l, :r, :u, :d best values when exiting from the location
  best = 9999999999
  path = []
  backtrack = Array.new(grid.length) { Array.new(grid.length) }
  seen = Array.new(grid.length) { Array.new(grid.length,nil) }
  seen[grid.length-1][grid.length-1] = grid.last.last

  dump = lambda do |label,g,len|
    puts label
    0.upto(len-1) do |y|
      0.upto(len-1) do |x|
        next unless g[y]
        printf " %6d",(g[y][x] || -1)
      end
    puts
  end

  end
  walk = lambda do |g,y,x,upto,in_from|
    # puts path.last.inspect
    # return nil unless we are on the grid 
    unless y >= 0 && x >= 0 && g[y] && g[y][x]
      print "+"
      return nil 
    end
    # return if we have been here before, cycle detection
    if backtrack[y][x]
      print "b"
      return nil 
    end
    # break out if we have seen better
    if upto + g[y][x] > best
#      print "o"
      return nil 
    end
    # enable cycle protection
    backtrack[y][x] = true


    # If we have been in this node before, it must have the smallest value
    # possible, since we will only set it's value after searching all
    # possible values from here.
    if seen[y][x]
      t = seen[y][x]
      puts path.last.inspect
#      puts "seen[#{y}][#{x}] = #{seen[y][x]}"
      path.reverse.each do |yy,xx,v|
#        puts "#{yy} #{xx} #{t}"
        t += g[yy][xx]
        seen[yy][xx] = t if (seen[yy][xx] || 999999999) > t
      end
      best = [best,t].min
#      puts "BEST = #{best}" if best == t
      r = t
    else
      # return nil if upto >= best 
      upto += g[y][x]
      cpath = [y,x,upto]
      path << cpath
      
      if true
        if in_from != :l && x < (g.length-1) && !backtrack[y][x+1]
          sum_r = walk.call(g,y,x+1,upto,:r) 
        end
        if in_from != :u && y < (g.length-1) && !backtrack[y+1][x]
          sum_d = walk.call(g,y+1,x,upto,:d)
        end
#        if in_from != :r && x > 0 && !backtrack[y][x-1]
#          sum_l = walk.call(g,y,x-1,upto,:l)
#        end
        if in_from != :d && y > 0 && !backtrack[y-1][x]
          sum_u = walk.call(g,y-1,x,upto,:u)
        end
      else
        sum_r = walk.call(g,y,x+1,upto,:r) unless in_from == :l
        sum_d = walk.call(g,y+1,x,upto,:d) unless in_from == :u
        sum_l = walk.call(g,y,x-1,upto,:l) unless in_from == :r
        sum_u = walk.call(g,y-1,x,upto,:u) unless in_from == :d
      end
      r = [sum_r,sum_l,sum_d,sum_u].compact.min

      # Save the smallest value found
#      puts "#{x} #{y} r = #{r}"
#      puts "XXXXXXXXXXXXXXXXX #{y} #{x} #{r}" if r
      if r
#        puts "#{r} = [#{sum_r},#{sum_l},#{sum_d},#{sum_u}].compact.min upto = #{upto}"
      end
      # remove path
      path.pop
      r
    end
    # remove cycle protection
    backtrack[y][x] = false
#    dump.call("exit y = #{y} x = #{x}",seen,seen.length)
    r
  end

  walk.call(grid.dup,0,0,0,nil)
  dump.call "FINISHED",seen,10
  dump.call "orig",grid,10

  puts seen[0][0]
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
    puts "n=#{n} x=#{x} y=#{y}" if best[0] >= (n - target).abs
    best = [best,[(n-target).abs,n,x,y]].min
    if n > target
      y -= 1
    else
      x += 1
    end
  end
  best[2] * best[3]
end

# Use pythagorian tripples with the sides of the form
# (x, y+z), (y, x+z), (z, x+y)
# So x, y and z < M
# Look at problem 75
def problem_86
end

# hmm... while I am only looking at each possible sequence of characters,
# I need to make sure to have an efficent way to count the number
# of permutations that can be made from each number sequence.
# The first version takes 12m33s, all of it in the permutation count code.
# The second version uses permutations and takes 0.64 seconds
# 8581146
def problem_92
  hit = 0
  seen = {0 => 0, 1 => 1, 89 => 89}

  check = lambda do |n|
#    puts n.inspect
    index = n.join.to_i
    return 0 if index == 0
    sum = index
    until seen[sum] do
      sum = sum.to_s.each_byte.map {|b| (b-48)*(b-48)}.reduce(&:+)
    end
#    puts "#{n} => #{seen[sum]}"
    seen[index] = seen[sum]
  end

  values = lambda do |a,off|
    (a[off-1] .. 9).each do |v|
      a[off] = v
      if off == (a.length-1)
        if check.call(a) == 89
          # now many uniq permutations of 'a' are there.
          if true
            hit += a.permutations
          else
            h = {}
            a.my_permutate {|a| h[a.join] = true }
            hit += h.size
          end
        end
      else
        values.call(a,off+1)
      end
    end
  end

  a = Array.new(7,0)
  values.call(a,0)
  puts "seen.length = #{seen.length}"
  hit
end

def problem_97
  p = 28433
  shift = 7830457
  shift_amount = 10_000
  mask = 10_000_000_000
  mod = (1 << shift_amount) % mask

#puts (p << shift) +1
#puts ((p << shift)+1) % mask
  loop do
    if shift > shift_amount
      p = (p * mod) % mask
      shift -= shift_amount
    else
      p = (p << shift) % mask
      break
    end
  end
  p += 1
  p.to_s[-10,10]
end

if __FILE__ == $0

  p problem_83
end

