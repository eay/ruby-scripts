#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'
require 'polynomial.rb'
require 'point.rb'

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
# 11,17,20,22,23,24 - 48 vs 47 - 6, 9,11,14,15
# 11,18,19,20,22,25 - 48 vs 47 - 7, 8, 9,11,14
#
# Rule 1) 
def problem_103

  rule1 = lambda do |a|
    low_sum = a[0,(a.length+1)/2].reduce(&:+)
    len = (a.length - 1)/2
    hi_sum  = a[-len,len].reduce(&:+)
    puts "#{low_sum} > #{hi_sum}"
    low_sum > hi_sum
  end

  a1 = [11,18,19,20,22,25]
  puts a1.inspect
  puts rule1.call(a1)
  # a = [20] + a1.map {|t| t+20}
  a = [20, 31, 38, 39, 40, 42, 45]
  # a is the starting point
  puts a.inspect
  puts rule1.call(a)
  exit
  a_max = 25
  b0 = a[0]
  num = 0
  (a[0]+1).upto(a[1]).each do |b1|
    (b1+1).upto(a[2]).each do |b2|
      (b2+1).upto(a[3]).each do |b3|
        (b3+1).upto(a[4]).each do |b4|
          (b4+1).upto(a[5]).each do |b5|
            (b5+1).upto(a[6]).each do |b6|
              puts [b0,b1,b2,b3,b4,b5,b6].inspect
              num += 1
            end
          end
        end
      end
    end
  end
  num
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

def problem_108
  n = 4
  q = nil
  loop do
    Primes.each do |p|
      x = p * n

      
    
      q = p
      n += 1
      break if n >= 1000
    end
    break
  end
end

if __FILE__ == $0
#  p problem_103
end


puts [81, 88, 75, 42, 87, 84, 86, 65].sort.inspect
puts [157, 150, 164, 119, 79, 159, 161, 139, 158].sort.inspect

a = [42, 65, 75, 81, 84, 86, 87, 88]
b = [79, 119, 139, 150, 157, 158, 159, 161, 164]

rule1 = lambda do |a|
  low_sum = a[0,(a.length+1)/2].reduce(&:+)
  len = (a.length - 1)/2
  hi_sum  = a[-len,len].reduce(&:+)
  puts "#{low_sum} > #{hi_sum}"
  low_sum > hi_sum
end

rule2 = lambda do |a|
  if a.uniq == a
    new = []
    a.each_cons(2) {|x,y| new << y - x}
    puts "a = #{a.inspect}"
    puts "n = #{new.inspect}"
  else
    false
  end
end

puts rule1.call(a)
puts rule2.call(a)
puts rule1.call(b)
puts rule2.call(b)
