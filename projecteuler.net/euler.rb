#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes'

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

if __FILE__ == $0
  p problem_24
end

