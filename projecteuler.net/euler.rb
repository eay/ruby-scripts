#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'
require 'polynomial.rb'

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


