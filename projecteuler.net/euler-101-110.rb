#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require_relative 'primes.rb'
require_relative 'groupings.rb'
require_relative 'polynomial.rb'
require_relative 'point.rb'

# Some-one elses solution
# Lagrange Interpolation
# def getnext(s,max)
#   (max-1).downto(0){|c|(0..c).each {|i| s[i]=s[i+1]-s[i]}}
#   s[0..max].inject(0){|sum,i| sum+i}
# end
#                  
# seq=(1..11).map {|i| i**10-i**9+i**8-i**7+i**6-i**5+i**4-i**3+i**2-i+1 }
# puts (0..9).inject(0){|s,i| s+getnext(seq.clone,i)}
#
def problem_101
  final = Polynomial.new [1,-1,1,-1,1,-1,1,-1,1,-1,1]
  terms = final.terms

  # The number sequence
  seq = (1..final.terms.length).map {|n| final.evaluate(n) }

  sum = 0
  1.upto(seq.length).each do |len|
#    puts "---\n#{seq[0,len].inspect}"
    p = Polynomial.optimum_solution(seq[0,len])
    break if p.terms ==  final.terms
#    puts p.terms.inspect
    bop = p.f(len+1)
    puts bop
    sum += bop
  end
  sum
end

# A Simple case of checking that the angle to the (0,0) is inside
# the angle to the other 2 points for all three points.
#
# Another solution was to see if the area of the three (0,0) triangles
# equals the area of the origional triangle.
#
# Another solution was that angles A0B, B0C, C0A must all be <= 180 degrees.
#
# One line must intersect the y-axis above, one must below, the other
# must not at all.
#
def problem_102
  triangles = []
  open("triangles.txt").each_line do |l|
    triangles << l.chomp.split(/,/).map(&:to_i)
  end
  puts triangles.length

  count = 0
  o = Point::Origin
  triangles.each do |p|
    p1 = Point.new(p[0],p[1])
    p2 = Point.new(p[2],p[3])
    p3 = Point.new(p[4],p[5])

    if p2.between(p1,o,p3) &&
       p1.between(p2,o,p3) &&
       p3.between(p1,o,p2)
      count += 1
    end
  end
  count
end

# 1) No combination of elements can be equal
# 2) More elements means bigger sum.
# From 1), all but S.min are greater than (S.max - S.min)
# Differences must be 1, 1, 2, 3, (4 or 5 or prime > 3?)
#
# From 2), smallest element must be > diff between set of n hi and
# n low.
# 20 + 31 + 38 + 39 == 128
# 40 + 42 + 45      == 127
#
# From 1) consider the non-first elements as
# 0, 7, 8, 9, 11, 14
# or 15 vs 34
# 11, 18, 19, 20, 22, 25
# so 48 vs 67
#
# 11,17,20,22,23,24 - 48 vs 47 - 6, 3, 2, 1, 1
# 11,18,19,20,22,25 - 48 vs 47 - 7, 1, 1, 2, 3
#
# I postulate that the diffs must be
# 1, 1, 2, 3, 5?
class Problem103
  # The sum(n) must be < than sum(n+1) elements
  def self.rule2(a)
    low_sum = a[0,(a.length+1)/2].reduce(&:+)
    len = (a.length - 1)/2
    hi_sum  = a[-len,len].reduce(&:+)
    low_sum > hi_sum
  end

  # No sum of subsets can be equal
  def self.rule1(a)
    return false unless a.uniq == a
    2.upto(a.length/2) do |n|
      a.combination(n) do |set_a|
        sum_a = set_a.reduce(&:+)
        b = a - set_a
        b.combination(n) do |set_b|
          return false if set_b.reduce(&:+) == sum_a
        end
      end
    end
    true
  end

  def self.check(a)
    rule2(a) && rule1(a)
  end
end

def problem_103
  a = [11,18,19,20,22,25]
  mid = a[a.length/2]
  a = [mid] + a.map {|t| t+mid}
  puts a.inspect

  min = [a.reduce(&:+),a]

  puts "end => #{a.inspect} => #{a.reduce(&:+)}" if Problem103.check(a)
  diffs = [1,1,2,3,4,5,6,7,8,9]
  a_len = a.length
  (a[0]).upto(a[0]+2) do |b0|
    puts b0
    b = [b0]
    (a[1]-4).upto(a[1]+2) do |b1|
      d_len = a_len-2
      b[1] = b1
      diffs.permutation(d_len) do |d|
        0.upto(d_len-1) do |i|
          b[i+2] = b[i+1] + d[i]
        end
        next unless Problem103.check(b)
        puts "good => #{b.inspect} => #{b.reduce(&:+)}"
        min = [min,[b.reduce(&:+),b]].min
      end
    end
  end
  puts min[1].inspect
  min[1].join
end

# A bit of a brute force, 8 seconds, so not too bad.  It could probably
# be improved in the number to string conversion
def problem_104
  all = ["1","2","3","4","5","6","7","8","9"]
  k = 2
  low_fn0,low_fn1 = 1,1
  hi_fn0,hi_fn1 =   1,1
  loop do
    k += 1
    low_fn0,low_fn1 =(low_fn0 + low_fn1) % 10_000_000_000, low_fn0
    hi_fn0, hi_fn1  = hi_fn0 +  hi_fn1,  hi_fn0
    if hi_fn0 > 1_000_000_000_000_000_000
      hi_fn0 /= 10
      hi_fn1 /= 10
    end
    front = false
    next unless k > 300
    hi  = hi_fn0.to_s[0,9].split(//)
    if (hi & all).length == 9
      puts "front #{k}" 
      front = true
    end
    if (low = low_fn0.to_s).length >= 9
      low = low[-9,9].split(//)
      if (low & all).length == 9
        puts "back  #{k}" 
        return k if front
      end
    end
  end
end

def problem_105
  good,sum = 0,0
  open("sets.txt").each do |l|
    set = l.chomp.split(/,/).map(&:to_i).sort
    if Problem103.check set
      good += 1 
      sum += set.reduce(&:+)
    end
  end
  puts "#{good} found"
  sum
end

# A bit hacky, but the answer is correct
def problem_106
  a = [1,2,3,4]
  a = [1,2,3,4,5,6,7]
  a = [1,2,3,4,5,6,7,8,9,10,11,12] 
  
  num = 0
  seen = {}
  # Don't do length of 1, they are ordered
  # Because they are size ordered, and 2 smalls are bigger than a large
  2.upto(a.length/2) do |n|
    puts "n = #{n}"
    a.combination(n) do |set_a|
      b = a - set_a
      break if b.length < n
      b.combination(n) do |set_b|
        key = [set_a,set_b].sort
        next if seen[key]
        seen[key] = true
        index = 0
        state = 0
        0.upto(set_a.length-1) do |i|
          break unless set_b[i] && set_a[i]
          if set_a[i] < set_b[i]
            state -= 1
          else
            state += 1
          end
        end

#        print "#{set_a.inspect} #{set_b.inspect} #{state}"
        if state.abs <= (set_a.length - 2) ||
          (state < 0 && set_a.last > set_b.last) ||
          (state > 0 && set_a.first < set_b.first)
#          puts " good"
          num += 1
        else
#          puts ""
        end
      end
    end
  end
  num
end

# A solution taken from the comments...
# I would be interested to work this out from first principals
# Anothers persons description on how to solve the problem is
# Here's my pencil/paper solution: 
#
# Let's take the set of numbers a_1 < a_2 < a_3 < ... < a_(2*n). How many 
# equal partitions of this set are trivially unequal? 
#
# Consider a partitioning of the numbers into sets S and T. Now imagine 
# the function f(m) = the number of elements a_i in S where i <= m. 
#
# If f(m) >= ceiling(m/2) for all 1<=m<=2*n, then the partition S and T 
# is trivially unequal, with the sum of set S < the sum of set T. This 
# is basically saying, as you step from m=1 to m=2*n, you've always 
# assigned more elements to set S than set T. Equivalentally, 
# if f(m) <= floor(m/2) for all 1<=m<=2*n, then the 
# sum of set S > the sum of set T. 
#
# Calculating the number of partitions that satisfy the above test is 
# equivalent to counting the number of paths through problem 15 that 
# stay below the main diagonal. So, graphically, we can calculate the 
# answer as follows on a 6x6 grid: 
#
# 1 
# | 
# 1--1 
# |  | 
# 1--2--2 
# |  |  | 
# 1--3--5--5 
# |  |  |  | 
# 1--4--9--14--14 
# |  |  |  |   | 
# 1--5--14-28--42--42 
# |  |  |  |   |   | 
# 1--6--20-48--90--132--132 
#
# The last number on each row indicates how many partitions of size 2*n
# are trivially unequal. So subtracting that from the number of total 
# partitions possible gives you the number you have to test: 
#
# 2*n = 2 --> 2C1/2 - 1 = 1 - 1 = 0 
# 2*n = 4 --> 4C2/2 - 2 = 3 - 2 = 1 
# 2*n = 6 --> 6C3/2 - 5 = 10 - 5 = 5 
# 2*n = 8 --> 8C4/2 - 14 = 35 - 14 = 21 
# 2*n = 10 --> 10C5/2 - 42 = 126 - 42 = 84 
# 2*n = 12 --> 12C6/2 - 132 = 462 - 132 = 330 
#
# To calculate the solution, you need to check the following number of subset
# pairs: 
#
# 12C2*0 + 12C4*1 + 12C6*5 + 12C8*21 + 12C10*84 + 12C12*330 = 21384 
#
# addendum: It turns out the numbers I calculated on the grid have a
# closed form: http://mathworld.wolfram.com/DyckPath.html
#
def problem_106a
  combin = lambda { |m,h| m.factorial / (h.factorial * (m - h).factorial) }
  max = 20

  sum = Array.new(max+1,-1)
  1.upto(max) do |n|
    0.upto(n/2) do |k|
      sum[n] += combin.call(n,2*k) * combin.call(2*k - 1, k + 1)
    end
    puts "#{n} #{sum[n]}"
  end
  sum[12]
end

# Quite easy, slowly borg in the other points, always sucking in the
# lowest link.
# From reading the solutions, I implemented what is called the
# Prim Algorithm.  I had also considered what is called
# Kruskal Algorithm but decided to go with the borg approch.
# http://students.ceid.upatras.gr/~papagel/project/contents.htm
def problem_107
  if false
    net = [ "-,16,12,21,-,-,-", "16,-,-,17,20,-,-", "12,-,-,28,-,31,-",
      "21,17,28,-,18,19,23", "-,20,-,18,-,-,11", "-,-,31,19,-,-,27",
      "-,-,-,23,11,27,-" ]
    net.map! {|line| line.split(/,/).map {|i| i == '-' ? nil : i.to_i}}
  else
    net = []
    open("network.txt").each do |line|
      net << line.chomp.split(/,/).map {|i| i == '-' ? nil : i.to_i}
    end
  end

  # Reformat into an array of nodes, with the their connections
  nodes = Hash.new {|h,k| h[k] = Hash.new }
  net.each_with_index do |row,i| # Each nodes is connected to...
    row.each_index do |col| # For each possible connection....
      # Add the node we are connected to and the cost
      nodes[i][col] = row[col] if row[col]
    end
  end

  initial = nodes.reduce(0) do |a,row|
    row[1].reduce(a) {|aa,p| aa + p[1] }
  end / 2
  # add to the 'borg' that is node0
  node0,node0_links = nodes.shift
  ans = []
  node0_contains = Hash.new
  node0_contains[node0] = true

  # What we do select the lowest link, the 'merge' it into node0, repeat
  while nodes.length > 0
    n,v = node0_links.min {|a,b| a[1] <=> b[1]}
    ans << [n,v] # Save the link for the answer
    node0_contains[n] = true # add to the 'borg' that is node0
    nodes[n].each_pair do |k,a| # Now merge in new poin, update vertexs
      next if node0_contains[k]
      node0_links[k] = [a, node0_links[k] || 1_000_000].min
    end
    nodes.delete(n)         # Remove from free nodes
    node0_links.delete(n)   # Remove from vertexes to resolve
  end

  now = ans.reduce(0) {|a,v| a + v[1]}
  puts "initial = #{initial}"
  puts "now     = #{now}"
  initial - now
end

# This has generated the numbers for me to calculate the formula
def problem_108a
  i = 4
  max = 0
  solve = {}
  loop do
    num = 0
    a = Rational(1,i)
    2.upto(i*2+1) do |j|
      if (a - Rational(1,j)).numerator == 1
        num += 1 
#        puts "(#{a} - #{Rational(1,j)} == #{a - Rational(1,j)}"
      end
    end

    solve[num] = [] unless solve[num]
    solve[num] << i.factors

    if num >= max
      puts "####################################"
      solve.each_key.sort.each do |k|
        s = solve[k].map do |v|
          h = {}
          v.each {|a| h[a] = (h[a] || 0) + 1 }
          h.values.sort.flatten
        end.uniq.sort
        puts "k = #{k} groups: #{s.inspect}"
#        puts solve[k].inspect
      end
      puts "#{i} = #{num} #{i.factors} #{i.factors.length + i.divisors.length}" 
      max = num
    end
    break if num > 1000
    i += 1
  end
  i
end

# I solved this one (and 110 as the same time) by myself :-), there are
# good comments though.
#
# From the notes;
# (n-x)(n-y) = n*n, this tells why the number of solutions equals the number of
# divisors of n^2 +1 divided by 2.
# If n is the product of the first k primes n^2 has 3^k divisors so n is
# smaller than product of the first 15 primes. (that solving klog3-6log10-log8=0).
# Then we must check if we can delete big primes and add powers to the small ones
# without affecting the inequality. But this is not a big task since 7^2=49 is
# bigger than 43. (clearly exponents should descend).
#
def problem_108(size = 1001)
  func = lambda do |a|
    if a.length == 1
      a[0]+1
    else
      m = a[0]
      (2*m+1) * func.call(a[1,a.length]) -m
    end
  end

  primes = Primes.upto(200)
  prime_number = lambda do |a|
    r = 1
    a.sort.reverse.each_with_index { |m,i| r *= primes[i] ** m }
    r
  end

  values = {}
  last = 0
  1.upto(100).each do |nn|
    nn.groupings do |a|
      sols = func.call a
      ans = prime_number.call a
#      puts "np=#{nn} sols=#{sols} ans=#{ans} => #{a.inspect}"
      if values[sols]
        values[sols] = [values[sols],[ans,a]].min
      else
        values[sols] = [ans,a]
      end
      true
    end
    size.upto(size*5/4) do |num|
      if values[num]
        puts "for np = #{nn} => #{num} => #{values[num].inspect}"
        if last == values[num]
          puts "factors = #{values[num][0].factors}"
          return values[num][0] 
        end
        last = values[num]
        break
      end
    end
    #values.sort.each do |k,v|
    #  puts "#{k} => #{v}"
    #end
  end
  nil
end

def problem_110
  problem_108(4_000_001)
end

if __FILE__ == $0
  p problem_110
end

