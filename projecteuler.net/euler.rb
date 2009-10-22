#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes'

def problem_41
  # hmm... if the sum of the digits is divisable by 3, it can never be prime,
  # so we only need to check 7 digits
  # pandigital = lambda { |n| (n.to_s.split(//) - ['0']).uniq.length == 9 }

  numbers = [7,6,5,4,3]
  work = [2,1]
  r = nil
  while numbers.length > 0
    work = [ numbers.pop ] + work
    next if work.reduce(&:+) % 3 == 0
    r = work.permutate do |a|
      n = a.map(&:to_s).join.to_i
#      puts n
      if n.prime?
#        puts "HIT #{n}"
        break n 
      end
    end
    puts "ans = #{r} for #{work.length} letters"
  #  p numbers.length
  #  puts "end"
  end
  r
end

if __FILE__ == $0
#  (999_999_999).times do |i|
#    n = Primes.factors(i)
#    o = Primes.factors_old(i)
#    puts "BAD #{i} o = #{o.inspect} n = #{n.inspect}" if Primes.factors(i) != Primes.factors_old(i)
#    puts i if i % 10_000 == 0
#    puts "HIT #{i}" if i.prime?
#  end
  p problem_41
end

