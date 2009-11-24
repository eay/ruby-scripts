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
# From the solutions;
# From an algorithmic point of view, this can be considered as a
# Bellman-Ford shortest path approach, rather than Dijkstra, as
# the computation does not proceed sequentially from the origin,
# but it is computed non-deterministically on all the nodes. As
# such, it should work well also with negative values, while
# Dijkstra shouldn't.
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

  last_times,last_sum = 3,big
  loop do
    y_len.times do |y|
      x_len.times do |x|
        me = cost[y][x]
        a = [ sums[y][x] ]
        a << sums[y][x-1] + me if x > 0
        a << sums[y][x+1] + me if x < x_len-1
        a << sums[y-1][x] + me if y > 0
        a << sums[y+1][x] + me if y < y_len-1
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

class Problem84
  Squares = %w{
    go   a1 cc1 a2  t1 r1 b1  ch1 b2 b3
    jail c1 u1  c2  c3 r2 d1  cc2 d2 d3
    fp   e1 ch2 e2  e3 r3 f1  f2  u2 f3
    g2j  g1 g2  cc3 g3 r4 ch3 h1  t2 h2
    }.map(&:to_sym)

  CommunityChest = [
    :go, :jail, nil, nil,
    nil, nil, nil, nil,
    nil, nil, nil, nil,
    nil, nil, nil, nil ]

  Chance = [
    :go, :jail, :c1,    :e3,
    :h2, :r1,   :nextrr, :nextrr,
    :nextu, :back3, nil, nil,
    nil, nil, nil, nil ]

  def initialize(sides = 6)
    @sides = sides
    @where = Squares.find_index(:go)
    @hits = Array.new(Squares.length,0)
    @chance = Chance.dup
    @community_chest = CommunityChest.dup
    @doubles = 0
  end

  # location is the symbolic name
  def do_community_chest(location)
    @community_chest = CommunityChest.dup if @community_chest.length == 0
    pick = @community_chest.delete_at(rand(@community_chest.length))
    location = pick if pick
    location
  end

  # location is the symbolic name
  def do_chance(location)
    @chance = Chance.dup if @chance.length == 0
    pick = @chance.delete_at(rand(@chance.length))
    case pick
    when :nextrr
      case location
      when :ch1 then ret = :r2
      when :ch2 then ret = :r3
      when :ch3 then ret = :r1
      end
    when :nextu
      case location
      when :ch1 then ret = :u1
      when :ch2 then ret = :u2
      when :ch3 then ret = :u1
      end
    when :back3
      case location
      when :ch1 then ret = :t1
      when :ch2 then ret = :d3
      when :ch3 then ret = do_community_chest(:cc3)
      end
    when nil
      ret = location
    else
      ret = pick
    end
  end

  @@die = Array.new(13,0)
  @@doubles = 0

  def roll
    d1 = rand(@sides) + 1
    d2 = rand(@sides) + 1
    @@die[d1+d2] += 1
    if d1 == d2
      @doubles += 1 
      @@doubles += 1
    else
      @doubles = 0
    end
    if @doubles == 3
      where = :jail
      @doubles = 0
    else
      where = Squares[(@where + d1 + d2) % Squares.length]
      case where
      when :g2j 
        where = :jail
      when :cc1, :cc2, :cc3
        where = do_community_chest(where)
      when :ch1, :ch2, :ch3
        where = do_chance(where)
      else
      end
    end
    @where = Squares.find_index(where)
    @hits[@where] += 1
  end

  def roll_dice(num_rolls = 1_000_000)
    num_rolls.times do
      roll
    end
  end

  def result
    total = @hits.reduce(&:+)
    s = @hits.zip(Squares).sort.reverse
    ret = "%02d" % Squares.find_index(s[0][1])
    ret += "%02d" % Squares.find_index(s[1][1])
    ret += "%02d" % Squares.find_index(s[2][1])
    s.reverse.each do |hits,sym|
      printf "%-6s %6.3f\n",sym.to_s,hits.to_f*100.0/total.to_f
    end

    puts "total = #{total}"
    puts "doubles = #{@@doubles}, should be #{total/@sides}"
    (2..(@sides*2)).each do |i|
      if i > @sides+1
        ans = total * (@sides*2 + 1 - i) / (@sides*@sides)
      else
        ans = total * (i - 1) / (@sides*@sides)
      end
      puts "#{i} #{@@die[i]} should be #{ans.to_i}"
    end
    ret
  end
end

def problem_84
  p84 = Problem84.new(4)
  p84.roll_dice(2_000_000)
  r = p84.result
  puts "101524 expected"
  r
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
# I need to search with prime multiples, and use factors to multiply the
# existing results
# Key things for next time, 
# given q <= q <= r
# then d = sqrt(r**2 + (p+q)**2) will be the shortest route
#
def problem_86a
  m = 1818
#  m = 100

  p3 = lambda do |mm,nn|
    raise "bad value" if mm == nn
    mm,nn = nn,mm if mm < nn
    m2 = mm*mm
    n2 = nn*nn
    a,b,c = [m2 - n2, 2*mm*nn, m2 + n2]
    [m2 - n2, 2*mm*nn, m2 + n2]
  end

  in_range = lambda {|a,b,c| a <= m && b <= 2*m}

  solutions = lambda do |ret,x,b,c|
    return unless x <= m
#    puts "#{x} #{b} #{c}"
    bm = (b >= m) ? m-1 : b-1
    bm = x-1 if x <= bm
    if x < b 
      ys = b - x
    else
      ys = 1
    end
    p1 = c.to_f # Math.sqrt(x**2 + (y+z)**2)
    z = b - ys
    if p1 <= Math.sqrt(ys**2 + (x+z)**2) &&
       p1 <= Math.sqrt(z**2 + (x+ys)**2)
      if false
        p = [b,x].sort
        if r = ret[p]
          puts "dup r = #{r} #{bm-ys+1}"
        end
        ret[p] = bm-ys+1
      else
        ys.upto(bm) do |y|
          ret[[x,y,b-y].sort] = true
        end
      end
    end
  end

  hits = Hash.new
  hit = 0
  (1..(m/2)).each do |x|
    ((x+1)..(m/2+1)).each do |y|
      next unless (x+y).odd? && x.gcd(y) == 1
      sides = p3.call(x,y).sort
      next unless in_range.call(*sides)
      hits[sides] = true
      hit += 1
    end
  end
  puts "Generated primative triangles"
  good = {}
  # Sort the primative triangles into sets according to
  # max M value.  Then for each increase, pick the groups with
  # factors into the M and solutions.call.
  # This should let us slide out.
  
  hits.each_key do |p|
    a,b,c = p
    (1..(2*m/([a,b].max))).each do |k|
      aa,bb,cc = a*k, b*k, c*k
      solutions.call(good,aa,bb,cc)
      solutions.call(good,bb,aa,cc)
#      good += solutions.call(aa,bb,cc)
#      good += solutions.call(bb,aa,cc)
    end
  end
#  good.compact!
  puts good.length
  puts "Triangles =>        #{hit}"
  puts "Unique Triangles => #{hits.length}"
#  good = good.map {|a| a.sort }.uniq.sort
#  good = good.sort.uniq
  puts "sorted"

#  hit = 0
#  good.each_pair do |p,v|
#    puts "#{p} => #{v}"
#    hit += v
#  end
#  puts "Hit = #{hit}"

  good.length
end

# The correct thing to notice is that going from 99 to 100, we only need to
# check the longest side for matches
# This works in 3 seconds vs the 4 minutes of my 86a.  Also note that
# my version was not incremental, so it was hard to know when to stop
def problem_86
  total = 0
  a = 1
  loop do
    a += 1
    aa = a*a
    (1..(a*2-1)).each do |d|
      tmp = Math.sqrt(aa + d*d)
      next if tmp != tmp.to_i

      e = d/2
      max_sols = e
      e += 1 if d.odd?
      expanded = a - e + 1
      total += (expanded > max_sols) ? max_sols : expanded
    end
    break if total > 1_000_000
  end
  a
end

def problem_87
  top = 50_000_000
  max2,max3,max4 = (2..4).map {|n| (Math::E ** (Math.log(top)/n)).to_i}
  p2,p3,p4 = [],[],[]
  Primes.each do |p|
    break if p > max2
    p2 << p**2 
    p3 << p**3 if p <= max3
    p4 << p**4 if p <= max4
  end

  hits = {}
  p4.each do |n4|
    p3.each do |n3|
      nn = n3 + n4
      break if nn + p2.first >= top
      p2.each do |n2|
        n = nn + n2
        break if n >= top
        hits[n] = true 
      end
    end
  end
  hits.length
end

# For a particular value of k, [k,2, 1 * (k-2)] is a solution.
# We can reduce this by converting numbers, i.e
# k=5: 10=[5,2,1,1,1] => 8=[2,2,2,1,1]
# k=27: 27=[3,3,3,1*24] 18=[3,3,3,1*15]
# We need numbers where their sum is < their multiple, then number of 1's
# add upto k
#
def problem_88
  max = 12000
#  2.upto(1200) do |k|
  ktab = []

  k_val = lambda do |n|
    mul = n.reduce(&:*) || 0
    sum = n.reduce(&:+) || 0
    k = n.length + (mul -sum)
    [k,mul,sum]
  end

  generate = lambda do |n|
    k,mul,sum = k_val.call(n)

    if k <= max
      if n.length >= 2
        if ktab[k]
          ktab[k] = [ktab[k],[mul,n.dup]].min
        else
          ktab[k] = [mul,n.dup]
        end
      end

      m = n + [2]
      generate.call(m) 

      while m.length <= 1 || m[-2] > m[-1]
        m[-1] += 1 
        break unless generate.call(m)
      end
      true
    else
      false
    end
  end

  m = [2]
  while m[0] <= max
    generate.call(m)
    m[0] += 1
  end

  ktab.map {|a| a ? a[0] : 0}.uniq.reduce(&:+)
end

# I == 1
# V == 5
# X == 10
# L == 50
# C == 100
# D == 500
# M == 1000
# There are smaller solutions that are not so carefull checking input, in python
#
# import re
# count = 0
# for s in open('roman.txt','r'):
#   l = len(s)
#   s = re.sub('IIII','IV',s)
#   s = re.sub('XXXX','XL',s)
#   s = re.sub('CCCC','CD',s)
#   s = re.sub('VIV','IX',s)
#   s = re.sub('LXL','XC',s)
#   s = re.sub('DCD','CM',s)
#   count += l - len(s)
# print count
#
# I personally don't like this kind of solition......
#
def problem_89
  convert = [
    [100,"CM","CD",/^(M*)(D?)(C*)$/,"M","D","C"],
    [ 10,"XC","XL",/^(C*)(L?)(X*)$/,"C","L","X"],
    [  1,"IX","IV",/^(X*)(V?)(I*)$/,"X","V","I"],
  ]

  saved = 0

  open("roman.txt").each_line do |txt|
    txt.chomp!
    if m = /^(M*?)(C?[DM]+C*|C*)??(X?[LC]+X*|X*)?(I?[XV]+I*|I*)?$/.match(txt)
      num = m[1].length * 1000
      (0..2).each do |i|
        mul,m9,m4,mr = convert[i]
        if m[i+2]
          case m[i+2]
          when nil
          when m9 then num += 9 * mul
          when m4 then num += 4 * mul
          when mr then num += (10 * $1.length + 5 * $2.length + $3.length)* mul
          else
            raise "unable to parse #{m[2]}"
          end
        end
      end
    else
      raise "unable to parse '#{txt}'"
    end
    txt_num = num
    out = ""
    convert.each do |mul,m9,m4,mr,m10,m5,m1|
      out << m10 * (num / (10*mul))
      num %= (10*mul)
      n = num / mul
      case n
      when 9 then out << m9
      when 4 then out << m4
      else
        if n >= 5
          out << m5 + m1 * (n - 5)
        else
          out << m1 * n
        end
      end
      num -= n * mul
    end

    puts "#{txt} => #{txt_num} => #{out} diff = #{txt.length - out.length}" 
    saved += txt.length - out.length
  end
  saved
end

# We are only dealing with [0,1,2,3,4,5,6,8]
# We only need to solve for
# [[0,1],[0,4],[0,6],[1,6],[2,5],[3,6],[4,6],[6,4],[8,1]]
#
# Ugly brute force, but hey, it works :-)
# 48sec
# I should really rework this using bits to represent the side values,
# this would speed up the check lambda alot
#
def problem_90
  # The 'pairs' we need are.
  # [2,5] is removed since it always needs to be present, as does
  # [1,8]
  # Otherwise we start with [1], [8] and 4 slots to fill
  # 0 -> 146
  # 6 -> 0134
  # We need to add 0 and 6 to each side, then fill in the missing ones
  # The starting values will be
  # [1] [] with 3/4 slots to fill.  Try all values and check for the correct
  # ones

  hits = Hash.new
  num = 0
  check = lambda do |ai,bi|
#    puts ai.inspect
    aa = ai.dup.map {|v| v == 9 ? 6 : v }
    bb = bi.dup.map {|v| v == 9 ? 6 : v }
    if aa.index(0) || bb.index(0)
      hit = []
      hit += bb & [1,4,6] if aa.index(0)
      hit += aa & [1,4,6] if bb.index(0)

      if hit.uniq.length == 3 && (aa.index(6) || bb.index(6))
        hit = []
        hit += bb & [0,1,3,4] if aa.index(6)
        hit += aa & [0,1,3,4] if bb.index(6)
        if hit.uniq.length == 4
          aas = ai.sort
          bbs = bi.sort
          aas,bbs = [aas,bbs].sort
          hits[aas] ||= Hash.new
          hits[aas][bbs] = true
      #    puts "HIT #{aas.inspect} #{bbs.inspect}"
          num += 1
        end
      end
    end
  end

  values = [0,1,2,3,4,5,6,7,8,9]

  va0 = values.dup
  vb0 = values.dup
  a[0],b[0] = 2,5
  va0.delete a[0]
  vb0.delete b[0]
  [1,8].each do |a1|
    va1 = va0.dup
    vb1 = vb0.dup
    if a1 == 1
      a[1],b[1] = 1,8
    else
      a[1],b[1] = 8,1
    end
    va1.delete a[1]
    vb1.delete b[1]
    va1.each do |a2|
      av2 = va1.dup
      a[2] = av2.delete a2
      av2.each do |a3|
        av3 = av2.dup
        a[3] = av3.delete a3
        av3.each do |a4|
          av4 = av3.dup
          a[4] = av4.delete a4
          av4.each do |a5|
            a[5] = a5
            vb1.each do |b2|
              bv2 = vb1.dup
              b[2] = bv2.delete b2
              bv2.each do |b3|
                bv3 = bv2.dup
                b[3] = bv3.delete b3
                bv3.each do |b4|
                  bv4 = bv3.dup
                  b[4] = bv4.delete b4
                  bv4.each do |b5|
                    b[5] = b5
                    check.call(a,b)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  puts "num = #{num}"
  total = 0
  hits.each_pair do |d1,v|
    v.each_key do |d2|
      total += 1
#      sixes = d1.select {|n| n == 6}.length
#      sixes += d2.select {|n| n == 6}.length
#      if sixes > 0
#        total += 2 ** sixes
#      else
#        total += 1
#      end
#      puts "#{d1.inspect} #{d2.inspect} sixes = #{sixes}"
      puts "#{d1.inspect} #{d2.inspect}"
    end
  end
  puts "total = #{total}"
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
  p problem_90
end


