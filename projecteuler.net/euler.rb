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

# Ugly, several goes, 320meg at runtime.  Slow, but works.  If it was
# done in C it would be fast enough.  The C version takes 9m30s
# Look at http://en.wikipedia.org/wiki/Floyd–Warshall_algorithm
# Recusion takes too long and it is hard to short circit it when
# you can move backwards.  They may be some multi-pass algorithm I could
# use.  Use a variant of 82, then serch for short cuts.
# I could use this current algorithm and then try joining short runs....
# It will be interesting to see how others solved this problem.
def problem_83b
  if true
    # Answer 2297
    cost = [
      [131, 673, 234, 103,  18],
      [201,  96, 342, 965, 150],
      [630, 803, 746, 422, 111],
      [537, 699, 497, 121, 956],
      [805, 732, 524,  37, 331]
    ]
    puts "Answer = #{2297}"
  else
    cost = open("matrix.txt").each_line.to_a.map do |l|
      l.chomp.split(/,/).map(&:to_i)
    end
    puts "Answer <= 427337"
  end
  len = cost.length
  len2 = len * len

  big = 9999999
  path = Array.new(len2*len2,big)

  path_set = lambda do |y,x,yy,xx,c|
    path[(y*len+x)*len2+yy*len+xx] = c
  end

  path2_set = lambda do |p1,p2,c|
    path[p1*len2+p2] = c
  end

  path_get = lambda do |y,x,yy,xx|
    path[(y*len+x)*len2+yy*len+xx]
  end
  path2_get = lambda do |p1,p2|
    path[p1*len2+p2]
  end

  (0...len).each do |y|
    (0...len).each do |x|
      path_set.call(y,x,y,x,   0)
      if x+1 != len
        path_set.call(y,x,y,x+1, cost[y][x+1])
        path_set.call(y,x+1,y,x, cost[y][x])
      end
      if y+1 != len
        path_set.call(y,x,y+1,x, cost[y+1][x]) 
        path_set.call(y+1,x,y,x, cost[y][x])
      end
      #puts "setup x=#{x} y=#{y} #{path_get.call(y,x,y,x)}"
    end
  end

  m = 0
  start = last = Time.now
  len2.times do |k|
    kl =k*len2
    len2.times do |i|
      next if k == i
      il = i*len2
      ilk = il+k
      len2.times do |j|
        next if (path[ilk] == big) || (path[kl+j] == big)
        m = path[ilk] + path[kl+j]
        print "#{path[ilk]} + #{path[kl+j]} "
        if path[il+j] > m
          path[il+j] = m
        end
        #m = [p1, p2+p3].min
#        puts " k = #{k} m = #{m}"
        puts "#{i} k=#{k} => #{j} #{m}"
      end
    end
    if false
      now = Time.now
      e = now - last
      last = now
      h,m,s = e / 3600, m = (e / 60) % 60, s = e % 60
      t1 = sprintf("%02d:%02d:%02d",h,m,s)
      e = ((now - start).to_f * len / (k+1)).to_i
      h,m,s = e / 3600, m = (e / 60) % 60, s = e % 60
      t2 = sprintf("%02d:%02d:%02d",h,m,s)
      puts "k=#{k} elapsed = #{t1} left = #{t2}"
    end
  end
  puts path_get.call(0,0,len-1,len-1) + cost[0][0]
end

# http://en.wikipedia.org/wiki/Dijkstra's_algorithm
# has problems
def problem_83a
  if false
    # Answer 2297
    cost = [
      [131, 673, 234, 103,  18],
      [201,  96, 342, 965, 150],
      [630, 803, 746, 422, 111],
      [537, 699, 497, 121, 956],
      [805, 732, 524,  37, 331]
    ]
    puts "Answer = #{2297}"
  else
    cost = open("matrix.txt").each_line.to_a.map do |l|
      l.chomp.split(/,/).map(&:to_i)
    end
    puts "Answer <= 425185"
  end
  x_len = cost.length
  y_len = cost.length

  distance = Array.new(y_len) { Array.new(x_len,9999999) }
  visited = Array.new(y_len) { Array.new(x_len,false) }

  adj = lambda do |y,x|
    ret = []
    ret << [y-1,x] if y > 0
    ret << [y,x-1] if x > 0
    ret << [y+1,x] if y+1 < y_len
    ret << [y,x+1] if x+1 < x_len
    ret
  end

  walk = lambda do |y,x,depth|
    puts "#{y} #{x} #{depth}"
    distance[0][0] = cost[0][0]
    ret = nil
    path = []
    loop do
#      puts "#{y} #{x}"
      if y+1 == y_len && x+1 == x_len
        ret = [distance[y][x],y,x]
        puts ret.inspect
        break 
      end
      c_dist = distance[y][x]
      nodes = adj.call(y,x).map do |yy,xx|
        next if visited[yy][xx]
        dist = cost[yy][xx] + c_dist
        if dist < distance[yy][xx]
          distance[yy][xx] = dist
        end
        [dist,yy,xx,0]
      end.compact
      if nodes.length > 0
        path = path + nodes.sort.reverse
      else
        puts "BAD #{y} #{x}"
      end

      visited[y][x] = true
#      puts path.last.inspect
      dd,y,x = path.pop
    end
    ret
  end

  walk.call(0,0,0)

end

# Solve via searching for neigbour. 0.11sec, the best way :-).
# Dijkstra's could also be used, but some tweaking is needed
def problem_83
  if false
    # Answer 2297
    cost = [
      [131, 673, 234, 103,  18],
      [201,  96, 342, 965, 150],
      [630, 803, 746, 422, 111],
      [537, 699, 497, 121, 956],
      [805, 732, 524,  37, 331]
    ]
    puts "Answer = #{2297}"
  else
    cost = open("matrix.txt").each_line.to_a.map do |l|
      l.chomp.split(/,/).map(&:to_i)
    end
    puts "Answer = 425185"
  end
  x_len = cost.length
  y_len = cost.length

  big = 999999999
  sums = Array.new(y_len) { Array.new(x_len,big) }

  sums[0][0] = cost[0][0]

  template = Array.new(4,big)
  last_sum = big
  last_times = 3
  loop do
    y_len.times do |y|
      x_len.times do |x|
        a = template.dup
        me = cost[y][x]
        a[0] = sums[y][x-1] + me if x > 0
        a[1] = sums[y][x+1] + me if x < x_len-1
        a[2] = sums[y-1][x] + me if y > 0
        a[3] = sums[y+1][x] + me if y < y_len-1
        a[4] = sums[y][x]
        sums[y][x] = a.min
      end
    end
    if last_sum == sums.last.last
      last_times -= 1
      break if last_times <= 0
    else
      last_sum = sums.last.last
    end
    puts sums.last.last
  end

  sums.last.last
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

