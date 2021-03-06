#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require_relative 'primes'

# What is the millionth lexicographic permutation of the
# digits 0, 1, 2, 3, 4, 5, 6, 7, 8 and 9?
def problem_24(number = 1_000_000, values = [0,1,2,3,4,5,6,7,8,9])
  values.sort!

  doit = lambda do |a,&block|
    if a.length == 2
      block.call [a[0],a[1]]
      block.call [a[1],a[0]]
    else
      b = a.dup
      c = b.shift
      a.each_index do |i|
        doit.call(b) do |r|
          block.call [c] + r
        end
        b[i],c = c,b[i]
      end
    end
  end

  i = 0
  doit.call(values) do |a|
    i += 1
    return a.map(&:to_s).join if i == number
  end
end

# What is the first term in the Fibonacci sequence to contain 1000 digits?
def problem_25
  n = 2
  a,b = 1,1
  finish = 10 ** 999
  begin 
    a, b, n  = a+b, a, n+1
  end while a < finish
  n
end

# Find the value of d < 1000 for which 1/d contains the longest
# recurring cycle.
def problem_26a
  # A bit of an evil cheat using RE.  The other solution is to keep track
  # of the remainder of the division until we see a repeat
  max,val,number = 0,0,0
  (2...1000).each do |n|
    v = (10**2002 / n).to_s
    if m = v.match(/(\d+?)(\1)+$/)
      number,max,val = n,m[1].length,m[1] if m[1].length > max
    end
  end
  number
end

# The better way to do it
def problem_26
  max_num,max = 0,0
  (2...1000).each do |n|
    rems = {0 => true}
    val = n
    rem = 10
    loop do
      rem *= 10 while rem < n
      rem = rem % n
      if rems[rem]
        max_num,max = n,rems.length if max < rems.length # rems.length -1
        break
      else
        rems[rem] = true
      end
    end
  end
  max_num
end

def problem_27
  # It can be solved by knowing
  # n² + n + 41 and n² - 79n + 1601 produce 40 and 80
  max_a,max_b,max = 0,0,0
  primes = Primes.upto(999)
  (-999..999).each do |a|
    primes.each do |b|
      n = 0
      while (v = n*n + a*n + b).prime?
        n += 1
      end
      max_a,max_b,max = a,b,n-1 if n-1 > max
    end
  end
  max_a * max_b
end

def problem_28(num = 1001)
#  rings = (num-1)/2 # Must be odd size
  (1..(num-1)/2).reduce(1) do |a,n|
    a + (4*n+2)**2 - 12*n
  end
end

def problem_29(num = 100)
  nums = {}
  (2..num).each do |a|
    (2..num).each do |b|
      nums[a**b] = true
    end
  end
  nums.length
end

def problem_30(power = 5)
  total = 0
  pow = {}
  10.times {|i| pow[i.to_s] = i**power}
  (2..(10**(power+1)-1)).each do |n|
    np = n.to_s.split(//).reduce(0) {|a,v| a + pow[v]}
    total += n if n == np
  end
  total
end

def problem_31(value = 200)
  coin_list = [1, 2, 5, 10, 20, 50, 100, 200]

  change = lambda do |amount,coins|
    coins = coins.dup
    coin = coins.pop
    num = 0
    num = change.call(amount,coins) if coins.length >= 1
    while coin <= amount do
      amount -= coin        # Take one coins worth at a time
      if amount == 0
        num += 1
      elsif coins.length >= 1
        num += change.call(amount,coins)
      end
    end
    num
  end
  change.call(value,coin_list)
end

def problem_32
  values = {}
  (1..9999).each do |x|
    xa = x.to_s.split(//)
    (1..99).each do |y|
      ca = (xa + y.to_s.split(//) + (x*y).to_s.split(//))
      if ca.length == 9 && (ca - ['0']).uniq.length == 9
        values[x*y] = true
        puts "#{x} * #{y} == #{x*y}"
      end
    end
  end
  values.keys.reduce(&:+)
end

def problem_33
  require 'rational'

  total = Rational(1)
  (1..9).each do |a|
    (1..9).each do |b|
      (1..9).each do |c|
        ra = Rational(c*10 + a, a*10 + b)
        rb = Rational(c, b)
        total *= ra if ra == rb &&  ra != 1
      end
    end
  end
  total.denominator
end

def problem_34
  f = (0..9).map(&:factorial)
  sum = 0
  (3..(9.factorial*7)).each do |n|
    s = n.to_s
    sum += n if n == s.split(//).reduce(0) {|a,c| a += f[c.to_i]}
  end
  sum
end

def problem_35
  num = 2 # 2 and 5
  Primes.upto(1_000_000) do |p|
    next if (s = p.to_s) =~ /[024568]/
    good = true
    (s.length-1).times do |i|
      s= s[1..-1] + s[0,1]
      unless s.to_i.prime?
        good = false
        break
      end
    end
    num += 1 if good
  end
  num
end

def problem_36
  1_000_000.times.select { |n|
    a = n.to_s(2)
    b = n.to_s(10)
    a == a.reverse && b == b.reverse
  }.reduce(0,&:+)
end

def problem_37
  fprime = lambda { |n|
    n.prime? && ((n < 10) || fprime.call(n.to_s[1,1_000_000].to_i))
  }
  bprime = lambda { |n|
    n.prime? && (( n < 10) || bprime.call(n.to_s.chop.to_i))
  }
    
  addp = lambda do |s,dir,&block|
    return if s.length >= 7
    %w{1 3 5 7 9}.each do |i|
      [i+s,s+i].each_with_index do |ns,i|
        next unless dir[i]
        ndir = fprime.call(ns.to_i), bprime.call(ns.to_i)
        next unless dir[i] == ndir[i]
        block.call(ns) if ndir[0] && ndir[1]
        addp.call(ns,ndir,&block)
      end
    end
  end
    
  hit = {}
  %w{1 2 3 5 7 9}.each do |s|
    addp.call(s,[true,true]) do |p|
      next if p.length  == 1
      hit[p] = true
    end
  end
  hit.keys.map(&:to_i).reduce(&:+)
end

def problem_38
  ret = []
  pandigital = lambda { |n| (n.to_s.split(//) - ['0']).uniq.length == 9 }
  100_000.times do |i|
    t = ""
    (1..9).each do |j|
      t += (i * j).to_s
      ret << t.to_i if t.length == 9 && pandigital.call(t)
      break if t.length >= 9
    end
  end
  ret.sort.last
end

def problem_39
  max_num,max_p = 0,0
  12.upto(1_000) do |p|
    num = 0
    a,b = p/2,1
    while (a > b)
      aabb = a*a + b*b
      cc = (p - a - b)**2
      if cc <= aabb
        num += 1 if cc == aabb #puts "#{a} #{b} #{c}"
        a -= 1
      else # cc > aabb
        b += 1
      end
    end
    if num > max_num
      max_num,max_p = num,p
      puts "#{max_p} #{num}"
    end
  end
  max_p
end

def problem_40
  s = ""
  num = 1
  while s.length <= 1_000_000
    s << num.to_s
    num += 1
  end
  total = 1
  7.times do |i|
    index = 10**i-1
    total *= s[index,1].to_i
    #puts "#{index} #{s[index,1]} #{s[index-10,20]}"
  end
  total
end

if __FILE__ == $0
  p problem_28
end

