#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'

class Problem68
  attr_accessor :value
  def to_s
    @value.to_s
  end
end

def problem_68
  p = 10.times.map { Problem68.new }
  lines = [
    [p[0],p[1],p[2]],
    [p[3],p[2],p[4]],
    [p[5],p[4],p[6]],
    [p[7],p[6],p[8]],
    [p[9],p[8],p[1]]]

  ans = []
  # To avoid sorting, only need to search with the first value
  # being 10, 9 or 8.  THis makes it about 3 times faster
  (8..10).each do |j|
    pa = (1..10).to_a
    pa.delete(j)
    pa.permutation do |values|
      values.unshift j 
      p.each_index { |i| p[i].value = values[i] }
      sum = lines.first.reduce(0) {|a,v| a + v.value }
      lines[1,lines.length-1].each do |a|
        s = a.reduce(0) {|a,v| a + v.value }
        unless s == sum
          sum = nil
          break
        end
      end
      if sum
        min = lines.map {|l| l[0].value}.min
        start = lines.index {|l| l[0].value == min}
        print "#{start}: "
        res = lines[start,lines.length-start].map do |ll|
          ll.map(&:to_s).join
        end.join
        res += lines[0, start].map do |ll|
          ll.map(&:to_s).join
        end.join
        puts "#{sum} #{res}"
        ans << res if res.length == 16
      end
    end
  end
  ans.map(&:to_i).sort.last
end

# Actually very simple, the number with the most prime factors <= 1e6.
# 510510
def problem_69
  n = 1
  Primes.each do |p|
    nn = n * p
    puts p
    break if nn > 1_000_000
    n = nn
  end
  n
end

# Brute force.  Correct but takes 40 minutes
def problem_70a
  all = []
  (2...10_000_000).each do |n|
    next if n.even? || n % 5 == 0
    t = n.totient
    if n.to_s.split(//).sort == t.to_s.split(//).sort
      puts "#{n} -> #{t} -> #{n.to_f/t}" 
      all << [n.to_f/t,n]
    end
  end
  all.sort.first
end

# Work from 2 big primes down, then 3 etc.  We see where the totient
# value will not be smaller.  Initially I did brute force, but before
# it had ended running, I had the optimized version nearly done, working
# from the other direction. There was a big speedup by passing the factors
# into the totient function (assuming they are known).
# NOTE:  If we know the factors, the totient function is trivial
# 8319823.factors => [2339, 3557]
#
# 1) 39m 00.70s Time for 70a - brute force
# 2)  0m 58.63s Time for 70 - without the 'last = qi' line
# 4)  0m 12.21s Time for 70
# 3)  0m  2.02s 2) with the - 'factors to totient'
# 5)  0m 00.27s 4) with the - 'factors to totient'
#
# On a side note, there was the conjecture that a prime can not be a
# permutation of it totient, the proof is
# ----
# RudyPenteado   (Assembler)  
#
# The proof for the conjecture:
#
# For a number to be a digit permutation of another, at least this 
# condition should be true: 
# 1) Both numbers need to be congruent (mod 9). 
# A prime number can only be congruent (mod 9) with these values: 
# 2) 1,2,4,5,7,8. 
# (those are the six phi(9) factors that are relatively prime to 9) 
# A prime-1 number can only be congruent (mod 9) with these values: 
# 3) 0,1,3,4,6,7. 
# (those are the same six phi(9) factors subtracted by one) 
# When you square a prime number the formula will be: 
# 4) (prim)(prim) 
# The phi of a squared prime will have the formula: 
# 5) (prim)(prim-1) 
# From 2) & 4), a prime square can only be congruent (mod 9) with: 
# 6) 1,4,7. Because (1,1=1 2,2=4 4,4=7 5,5=7 7,7=4 8,8=1) 
# From 3) & 5), the phi(prime-sqrd) can only be congruent (mod 9) with: 
# 6) 0,2,3,6. Because (0,1=0 1,2=2 3,4=3 4,5=2 6,7=6 7,8=2) 
# Since a squared prime and its phi cannot be congruent (mod 9), they 
# also cannot be a permutation of each other. 
#
# Regards, 
# Rudy.
# ---
# As a followup,
# ---
# euler   (PHP)  
#
# What an excellent proof, Rudy. Bravo! 
#
# Building on your approach, the proof can be slightly optimised by working
# modulo 3, and extended for the case pk. First let us consider φ(p2)... 
#
# We know that the remainder of a number when divided by 3 is the same as
# the remainder of the sum of the digits. For example, 37≡1 mod 3,
# and 3+7=10≡1 mod 3. More importantly, changing the order of the digits
# will not change the remainder. 
#
# So if φ(p2) is a permutation of p2, then they will both be
# congruent modulo 3. 
#
# We note that, φ(p2)=p(p-1). 
#
# With the exception of 3, 
# p≡1,2 mod 3 
# p−1≡0,1 mod 3 
# p(p−1)≡0,2 mod 3 
# p2≡1 mod 3 
#
# As φ(p2)=p(p−1) is never congruent with p2 mod 3, we deduce that they
# cannot be a permutation of one another. 
#
# Similarly, the proof can now be extended for pk, but it does become a
# lttle clumsy... 
#
# p≡1,2 mod 3 
# p−1≡0,1 mod 3 
#
# Next we note that φ(pk)=pk−1(p−1) 
#
# If k is even, 
# pk≡1 mod 3 
# pk−1≡1,2 mod 3 
# pk−1(p-1)≡0,2 mod 3 
# Hence pk cannot be a permutation of φ(pk) when k is even. 
#
# If k is odd, 
# pk≡1,2 mod 3 
#
# Case (1): if p≡1 mod 3, p−1≡0 mod 3 
# pk≡1 mod 3, pk−1≡1 mod 3 
# pk−1(p−1)≡0 mod 3 
#
# Case (2): if p≡2 mod 3, p−1≡1 mod 3 
# pk≡2 mod 3, pk−1≡1 mod 3 
# pk−1(p−1)≡1 mod 3 
#
# So whichever way, φ(pk) cannot be a permutation of pk.
#
# ---
# On to the solution!
def problem_70
  size = 10_000_000
  primes = Primes.upto(Math.sqrt(size*3/2).to_i).reverse

  min = [10.0,0]
  p = primes[0]
  last = primes.length
  primes.each_index do |pi|
    p = primes[pi]
    (pi...last).each do |qi|
      q = primes[qi]
      n = p*q
      next if n >= size
      t = n.totient(p,q) # Pass in the factors to make it faster
      if n.to_s.split(//).sort == t.to_s.split(//).sort
        puts "#{p} * #{q} == #{n} -> #{t} -> #{n.to_f/t}" 
        min = [min,[n.to_f/t,n]].min
        # Next time, we don't need to go lower, since this will only
        # make the totient larger, since we still only have 2 numbers
        last = qi
        break
      end
    end
  end
  min
end

if __FILE__ == $0
  p problem_70
end

