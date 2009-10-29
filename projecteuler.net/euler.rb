#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'

def problem_50
  primes = []
  Primes.each do |p|
    break if p >= 5000 # 4920 - last 21 terms sum > 1_000_000
    primes << p
  end
  max,max_p = 0,0
  reset = false
  top = 1
  bottom = 0
  sum = primes[bottom] + primes[top]
  sum_total = sum
  while top < primes.length do
    return(max_p) if sum > 1_100_000
    if sum.prime?
      tb = top-bottom+1
      if tb > max && sum < 1_000_000
        max,max_p = tb,sum
        puts "Prime #{sum} #{tb}"
      end
    else
      if bottom + 1 != top
        sum -= primes[bottom]
        bottom += 1
        next
      end
    end
    top += 1
    sum_total += primes[top]
    sum = sum_total
    bottom = 0
  end
end

# 121313
def problem_51
  num = 6
  min_size = 10**(num-1)

  puts "start"
  prime = min_size + 1
  loop do
    prime += 2
    next unless prime.prime?
    n = prime.to_s
    next unless n.split(//).uniq.length < n.length
    a = n.split(//)
    ca = a.remove(a.uniq).uniq 
    ca.each do |c| # For each repeated character
      indexes = n.indexes(c) # The locations of the repeated digits
      test = a.dup
      count = [ a.join("").to_i ]
      ("0".."9").each do |rep|
        indexes.each {|i| test[i] = rep }
        h = test.join("").to_i
        if h.prime? && h >= min_size
          count << h
        end
      end
      count.uniq!
      if count.length == 8
        puts count.inspect
        return count.sort.first
      end
    end
  end


  if false
  match = []
  (0..(num-2)).each do |index| # -2 because bottom digit can't change much
    match[index] = []
    (0..9).each do |d|
      c = d.to_s
      r = []
      r << sp.select do |n|
        n[index] == c && n.count(c) > 1
      end
      (3..num).each do |t|
        r << r[0].select {|n| n.count(c) == t} || []
      end
      p r.length
      puts "(#{index},#{c}) => #{r[0].length} #{r[1].length} #{r[2].length} #{r[3].length}"
      match[index][c.to_i] = r
      puts r[2].inspect if r[2].length == 10
    end
  end
  end
end

def problem_52
  start = 100_000
  n = start
  nn = 167_000 # 1.67 * 6 will overflow
  loop do
    if n >= nn
      nn *= 10
      start *= 10
      n = start
    else
      n += 1
    end
    s = n.to_s.split(//).sort
    bad = false
    (2..6).each do |t|
      unless (n*t).to_s.split(//).sort == s
        bad = true
        break
      end
    end
    return n unless bad
  end
end

def problem_53
  nCr = lambda {|n,r| n.factorial / (r.factorial * (n-r).factorial) }
  count = 0
  (1..100).each do |i|
    (1..i).each do |j|
      if nCr.call(i,j) > 1_000_000
        count += 1 
      end
    end
  end
  count
end

def problem_67
  problem_18(open("triangle.txt").read.split(/\s+/).map(&:to_i))
end

if __FILE__ == $0
  p problem_51
end

