#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'
#require 'polynomial.rb'
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

if __FILE__ == $0
  p problem_112
end

