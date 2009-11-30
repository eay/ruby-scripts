#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'
require 'polynomial.rb'

def problem_101
  final = Polynomial.new [1,-1,1,-1,1,-1,1,-1,1,-1,1]
  terms = final.terms
  puts final

  1.upto(terms.length).each do |len|
    p = Polynomial.new(terms[0,len])
    (1..10).each {|i| puts p.f(i) }
  end

  nil
end

def problem_102
  triangles = []
  open("triangles.txt").each_line do |l|
    triangles << l.chomp.split(/,/).map(&:to_i)
  end
  puts triangles.length
end

if __FILE__ == $0
  p problem_101
end


