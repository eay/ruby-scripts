#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'euler.rb'

def problem_67
  problem_18(open("triangle.txt").read.split(/\s+/).map(&:to_i))
end

puts problem_67

