#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes'

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
  rings = (num-1)/2 # Must be odd size
  (1..(num-1)/2).reduce(1) do |a,n|
    a + (4*n+2)**2 - 12*n
  end
end

if __FILE__ == $0
  p problem_28
end

