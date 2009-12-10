#!/usr/bin/env ruby1.9
#
require 'primes.rb'
require 'groupings.rb'
require 'polynomial.rb'

def solutions(a)
  loop do
    a.sort!
    if a.length == 1 # Single term
      return a.length + 1
    end
    if a - [1] == [] # for all ones
      sum = 2
      2.upto(a.length) do
        sum = sum * 3 -1
      end
      return sum
    end
    # [1,4], [1,10]
    if a.length == 2 && a[0] = 1
      a = a[1] * 3 + 1
    end
  end
end


(1..100).each do |i|
  s = solutions([1] * i)
  puts "#{i} #{s}"
  break if s > 4_000_000
end

def fmn(*a)
  a = a.flatten
  if a.length == 1
    a[0]+1
  else
    m = a[0]
    (2*m+1) * (fmn(a[1,a.length])) - m
  end
end

puts "[n]"
puts "n+1"
puts "[1,n]"
puts Polynomial.optimum_solution([5,8,11,14,17,20,23,26]).to_s
puts "[2,n]"
puts Polynomial.optimum_solution([8,13,18,23,28]).to_s
puts "[3,n]"
puts Polynomial.optimum_solution([11,18,25,32,39]).to_s
puts "[4,n]"
puts Polynomial.optimum_solution([14,23,32,41,50]).to_s
puts "[5,n]"
puts Polynomial.optimum_solution([17,28,39,50,61,72]).to_s

puts "[1,1,n]"
puts Polynomial.optimum_solution([14,23,32,41,50,59]).to_s
puts "[1,2,n]"
puts Polynomial.optimum_solution([23,38,53,68]).to_s

puts "[2,2,n]"
puts Polynomial.optimum_solution([38,63,88,113]).to_s
puts "[2,3,n]"
puts Polynomial.optimum_solution([53,88,123,158]).to_s
puts "[2,4,n]"
puts Polynomial.optimum_solution([68,113,158,203]).to_s

puts
puts "[4,5] #{fmn(4,5)}"
puts "[4,8] #{fmn(4,8)}"
puts "[3,5] #{fmn(3,5)}"
puts "[5,3] #{fmn(5,3)}"
puts
puts "[2,4,4] #{fmn(2,4,4)}"
puts "[2,2,2,2] #{fmn(2,2,2,2)}"
puts "[1,1,1,1] #{fmn(1,1,1,1)}"
