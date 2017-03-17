#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require './primes.rb'
require './groupings.rb'
require './polynomial.rb'
#require 'point.rb'

# To solve this one, we make a template of 10 of the digit we are checking
# and then, for the number of 'replacements', permutate that number from
# all possible replacement locations.
# Then for each 'set' of replacement locations, try all possible values.
# We could prune this better, but we simply discard leading zero's and if
# the last digit is not in [1,3,7,9].
# We could perhaps do the sum % 3 != 0 test, but it would probably not 
# improve things much.
def problem_111(num_digits = 10)
  digits = (0..9).to_a
  last = [1,3,7,9]
  total = 0
  hits = {}
  (0..9).each do |digit|
    d_found,d_sum = 0,0
    array = [digit] * num_digits
    (1).upto(num_digits-1) do |num_replacements|
      # We have an array of the search digit, then we
      # generate 'n' length permutations of all available locations
      # and place our 'replacement' numbers in those locations.
      rep_finish = 10**num_replacements

      slots = Array.new(num_digits) {|i| i}
      # We use p_seen as a simple way to stop the duplicate value
      # problem, since we permutate over all replacement combinations
      # and we try all values each time.
      p_seen = {}
      slots.permutation(num_replacements) do |rep|
        # Remove permutation duplication
        reps = rep.sort
        next if p_seen[reps]
        p_seen[reps] = true

        # Put replacement values in the 'rep' locations.
        # We do this by just incrementing a number and chopping it up into
        # the locations
        test = array.dup
        v = 0 # want it visable outside
        0.upto(10**num_replacements) do |rep_value|
          rep.each do |i|
            v = rep_value % 10
            break if v == digit
            test[i] = v
            rep_value /= 10
          end
          next if v == digit
          # no leading 0's
          # skip if the last digit stops us being prime
          next unless last.member? test[-1]
          next if test[0] == 0
          if (t = test.join.to_i).prime?
            d_found += 1
            d_sum += t
            hits[t] = true
          end
        end
      end
      if d_found > 0
        total += d_sum
        puts "M(#{num_digits},#{digit})=#{num_digits - num_replacements} " +
          "N(#{num_digits},#{digit})=#{d_found} " +
          "S(#{num_digits},#{digit})=#{d_sum}"
        break 
      end
    end
  end
  total
end

# Lets just do a simple brute force check, 1.5sec
def problem_112
  bouncy = 0
  num = 100
  loop do
    bouncy += 1 if num.bouncy?
    break if num * 99 == bouncy * 100
    num += 1
  end
  num
end

def problem_113
  # The index is the lowest value seen
  u = Array.new(10,0)
  # The index is the only values seen
  s = Array.new(10,1)
  # The index is the highest value seen
  d = Array.new(10,0)

  t = Array.new(10,0)
  total = 9
  (2..100).each do |z|
    ru,rs,rd = t.dup,t.dup,t.dup
    # rember that adding a leading 0 changes nothing
    10.times do |last_d|
      10.times do |next_d|
        if last_d == 0 && next_d == 0
        end
        ru[next_d] += u[last_d] if next_d <= last_d
        rd[next_d] += d[last_d] if next_d >= last_d

        ru[next_d] += s[last_d] if next_d < last_d
        rs[next_d] += s[last_d] if next_d == last_d
        rd[next_d] += s[last_d] if next_d > last_d
      end
    end
    puts ru.inspect
    puts rs.inspect
    puts rd.inspect
    total = total + [ru + rs + rd].flatten.reduce(&:+) - ru[0] - rs[0]
    puts "1e#{z} => #{total}"
    u,s,d = ru,rs,rd
  end
  total
end

# We solve this problem by breaking the problem into the number of red blocks
# and the number of black blocks.  We will account for the ends by adding
# 2 blocks.  So, for 4 squares we can have
# [[4], [3]] for red blocks and
# [1,1] and [1,2] for black blocks
# 5.7sec, could probably be much quicker if I cleaned up the
# groupings method to only allocate into 'n' buckets.
# Some people used recursion, this method uses partitioning
def problem_114a(squares = 50)
  num = 1 # Allow for all black

  # Return the number of possible allocations
  comb = lambda do |num,items|
    return 1 if num == 1 || items == 0
    return num if items == 1
    ret = num # Allow for [num,0,0], [0,num,0], [0,0,num]
    items.groupings do |a|
      if a.length <= num
        while a.length < num
          a << 0
        end
        #puts "items => #{a.inspect}"
        ret += a.permutations
      end
      true
    end
    ret
  end

  min_size = 3
  max_red_blocks = (squares+1)/(min_size+1)
  1.upto(max_red_blocks) do |red_blocks|
    # red_blocks is the number of red elements
    # black_blocks is the number of black elements
    black_blocks = red_blocks + 1
    (red_blocks*min_size).upto((squares - red_blocks) + 1) do |red_squares|
      keep = []
      black_squares = squares - red_squares + 2
      
      rs = comb.call(red_blocks,red_squares - red_blocks * min_size)
      bs = comb.call(black_blocks,black_squares - black_blocks)
      puts "rb = #{red_blocks}/#{red_squares} bs = #{black_blocks}/#{black_squares} => rs=#{rs} bs=#{bs}"
      num += rs * bs
    end
  end
  num
end

# retusive with caching, 0.032sec
def problem_114(min = 3, number = 50, cache = {})
  solve = lambda do |n|
    if r = cache[n]
      r
    else
      # If no space left, just report the current item.
      if n <= min - 1 
        r = 1
      else
        num = 1 # The current status plus what we can add
        (0 .. (n-min)).each do |d| # Black 0 to last red long
          (min .. (n-d)).each do |t| # One Red
            # See how many we can fit into what is left
            num += solve.call(n - d - t - 1)
          end
        end
        r = num
      end
      cache[n] = r
      r
    end
  end
  solve.call(number)
end

# 0.67sec
def problem_115(m = 50)
  cache = {}
  n = m + 1
  loop do
    r = problem_114(m,n,cache)
    puts "F(#{m},#{n}) => #{r}"
    return(n) if r > 1_000_000
    n += 1
  end
end

# Note, there does not need to be alternating tiles
# Quite easy to solve
def problem_116(m = 50)
  red   = m.tiling([1,2]) - 1
  green = m.tiling([1,3]) - 1
  blue  = m.tiling([1,4]) - 1
  puts "red = #{red} blue = #{blue} green = #{green}"
  red + green + blue
end

def problem_117(m = 50)
  m.tiling([1,2,3,4])
end

# It takes just over 1 minute 
# Udate, 55sec
def problem_118
  # Return hash with the keys being a sorted array or sorted arrays of
  # suitable elements
  def problem_118_solve(set,d)
    good = {}
    d.length.downto(1) do |n|
      d.combination(n) do |a|
        # Trivial prime check
        next if n > 1 && a.reduce(&:+) % 3 == 0
        rem = (d - a).sort
        # If only one digit left, make sure it is prime
        a.permutation do |p|
          if p.join.to_i.prime?
            if rem.length == 0
              good[(set.dup << a).sort] = true
              # puts good.last.inspect
            else
              good = good.merge problem_118_solve(set.dup << a,rem.sort)
            end
            break
          end
        end

      end
    end
    good
  end

  puts "Find sets"
  good = problem_118_solve([],[1,2,3,4,5,6,7,8,9]).keys
  # good is an array of sets that have at least one solution
  hits = 0
  cache = {}
  puts "Number of digit groupings is #{good.length}"
  puts "Permutate sets"

  good.each do |a|
    times = 1
    # For each element, how many primes can we make
    a.each do |p|
      unless t = cache[p]
        if p.length == 1 # Must be prime
          t = 1
        else
          t = 0
          p.join.to_i.permutation do |q|
            t += 1 if q.prime?
          end
        end
        cache[p] = t
      end
      times *= t
    end
    hits += times
  end
  hits
end

def problem_119
  hits = {}
  200.times do |x|
    20.times do |y|
      z = x ** y
      next unless z >= 10
      sum = z.to_s.split(//).map(&:to_i).reduce(&:+)
      hits[z] = true if sum == x
    end
  end
  hits.keys.sort[30-1]
end

# Solves it with brute force, there is a better way.
# 244sec 333082500
def problem_120a
  m = []
  3.upto(1000) do |a|
    a2 = a*a
    ni,pi = (a-1),(a+1)
    mm = 0
    (ni * pi).times do |ch|
      mm = [mm,(ni + pi) % a2].max
      ni = (ni * (a-1)) % a2
      pi = (pi * (a+1)) % a2
    end
    puts "a=#{a} m=#{mm}"
    m << mm
  end
  m.reduce(&:+)
end

# Fast version, 1sec, keep on searching until we have seen the current
# max again, this means we are in a loop.
# The following relationship holds, but I'm not really sure if it
# would make things much faster to calculate since the addition
# cycles still need to be calculated
# (a+1)^2 % a^2 => a^2 + 2a + 1 => 2a + 1
# (a+1)^3 % a^2 => (2a + 1) * (a + 1) => 3a + 1, so a*n + 1
# Same for (a-1)^n, leads to 
# (a*n - 1) for odd and
# (1 - a*n) for even
def problem_120b
  m = []
  3.upto(1000) do |a|
    a2 = a*a
    v0 = a - 1
    v1 = a + 1
    max = (v0 + v1) % a2
    loop do
      v0 = (v0 * (a-1)) % a2
      v1 = (v1 * (a+1)) % a2
      sum = (v0 + v1) % a2
      break if max == sum
      max = [max,sum].max
    end
    puts "a=#{a} m #{max}"
    m << max
  end
  puts 333082500
  m.reduce(&:+)
end

# 0.45s of a second using rationals
# ANS => 2269
def problem_121a(turns = 15)
  turn_list = (0...turns).to_a
  red_prob = turns.times.reduce([]) do |p,turn|
    p << Rational(turn+1,turn+1+1)
  end
  blue_prob = red_prob.map {|p| Rational(1) - p }

  # Work out the chance of loosing, a bit less work.
  total = Rational(0)
  (turns/2+1).upto(turns) do |num_blue|
    turn_list.combination(num_blue) do |blues|
      reds = turn_list - blues
      rp = reds.reduce(Rational(1)) { |a,b| a * red_prob[b] }
      bp = (turn_list - reds).reduce(Rational(1)) { |a,b| a * blue_prob[b] }
      p = rp * bp
      total += p
    end
  end
  (Rational(1) / total).to_i
end

# 0.31s using float
# ANS => 2269
def problem_121f(turns = 15)
  turn_list = (0...turns).to_a
  red_prob = turns.times.reduce([]) do |p,turn|
    p << (1.0+turn)/(1.0+1.0+turn)
  end
  blue_prob = red_prob.map {|p| 1 - p }

  # Work out the chance of loosing, a bit less work.
  total = 0.0
  (turns/2+1).upto(turns) do |num_blue|
    turn_list.combination(num_blue) do |blues|
      reds = turn_list - blues
      rp = reds.reduce(1.0) { |a,b| a * red_prob[b] }
      bp = (turn_list - reds).reduce(1.0) { |a,b| a * blue_prob[b] }
      p = rp * bp
      total += p
    end
  end
  (1.0 / total).to_i
end

# using recursion 0.07s
def problem_121(turns = 15)
  blue_wins = turns/2+1
  win = lambda do |idx,turns, blue|
    return 1.0 if blue == blue_wins # turns/2+1
    return 0.0 if idx == turns
    nballs = 2.0 + idx
    (win.call(idx+1,turns,blue+1) + 
     (nballs-1) * win.call(idx+1,turns,blue)) / nballs
  end

  (1/win.call(0,turns,0)).to_i
end

def problem_122a(max = 200)
  v = {1 => 0, 2 => 1}
  n = 4
  loop do
    v.keys.each do |k|
      v[k+k] = v[k] + 1
    end
    best = 1_000_000
    vv = v.dup
    v.keys.combination(2) do |a,b|
      puts "#{a} #{b}"
      if a+b == n
        puts "HIT #{a}[#{v[a]}] #{b}[#{v[b]}] => #{v[a] + v[b] + 1}"
        best = [best,v[a] + v[b] + 1].min
      else
        vv[a+b] = v[a] + v[b] + 1
      end
    end
    return best if best < 1_000_000
    v = vv
  end
end

def problem_122(max = 200)
  # Return an array of [number, steps]
  doit = lambda do |d,max|
    ret = d.dup
    while ret.last[0] < max
      ret << [ret.last[0]*2,ret.last[1]+1]
    end
    ret
  end

  num_adds = lambda do |a,num|
    steps = 0
    d,n = a,num
#    puts d.inspect
#    puts num
    while n > 1
      d = d.select {|i| i[0] <= n }
      if steps == 0
        steps = d.last[1]
      else
        steps += 1
      end
      n -= d.last[0]
    end
    steps += 1 if n == 1
    steps
  end

#  seive = Array.new(num) { false }
#  seive[0] = true
#  seive[1] = true
  arrays = []
#  while i = seive.index(false)
#    Build up the arrays
#  end
  arrays << doit.call([[1,0],[2,1]],max)
  arrays << doit.call([[1,0],[2,1],[3,2]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[5,3]],max)
  arrays << doit.call([[1,0],[2,1],[4,2],[5,3]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[5,3],[7,4]],max)
  arrays << doit.call([[1,0],[2,1],[4,2],[5,3],[7,4]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[4,3],[5,4]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[6,3],[9,4]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[6,3],[8,4],[11,5]],max)
  arrays << doit.call([[1,0],[2,1],[4,2],[8,3],[12,4]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[5,3],[8,4],[13,5]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[6,3],[12,4],[14,5]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[6,3],[12,4],[15,5]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[6,3],[7,4],[13,5]],max)
  arrays << doit.call([[1,0],[2,1],[3,2],[5,3],[7,4],[14,5],[21,6]],max)

  total = 0
  1.upto(max) do |i|
    ret = i
    arrays.each do |dd|
      ret = [ret,num_adds.call(dd,i)].min
    end
    puts "#{i} -> #{ret}" #if ret > 10
    total += ret
  end
  total
end

def problem_123(max = 10**10)
  n = 0
  Primes.upto(1000000) do |p|
    n += 1
    
    if true
      # From problem 120, 1.065s
      # (p**n +1) % p**2 => n*p+1
      # (p**n -1) % p**2 => odd, even => n*p-1, 1-np
      # add together and for odd, we get 2np
      break if n.odd? && (2*n*p) > max
    else # Simple, brute force: 68.014s
      r = ((p-1)**n + (p+1)**n) % (p*p)
      break if r > max
    end
  end
  n
end

if __FILE__ == $0
  p problem_123
end

