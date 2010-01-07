#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'
require 'polynomial.rb'
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

if __FILE__ == $0
  p problem_117
end

