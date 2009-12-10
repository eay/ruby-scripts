#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'
#require 'polynomial.rb'
#require 'point.rb'

def problem_110(num_digits = 10)
  digits = (0..9).to_a
  last = [1,3,7,9]

  def p_110(missing,padding,padding_num,&block)
    (missing + digit_array).permutations(num_digits) do |g|
      yield g
    end
  end

  total = 0
  hits = {}
  # Since all the same 'digit' is not prime, start at d-1
  (0..9).each do |digit|
    d_found,d_sum = 0,0
    (num_digits - 1).downto(1) do |digit_length|
      sum = digit_length * digit
      digit_array =  [digit] * digit_length
      (digits - [digit]).combination(num_digits - digit_length) do |missing|
        next if missing.reduce(sum,&:+) % 3 == 0
#        puts "d=#{digit} #{([digit] * digit_length).inspect}#{missing.inspect}"
        
        # Must do this better
        # Loop over all 'missing' permutation, but insert the digit in
        # the gaps
        puts "missing = #{missing.inspect}"
        missing.permutation do |perm|
          puts "perm = #{perm.inspect}"
          # We now need to 'fill in the gaps'
          (perm.length + 1).groupings do |g|
            ex = perm.length + 1 - g.length
            g += [0] * ex
            puts "g = #{g.inspect}"
            gg = g.map {|n| [digit] * n}
            # gg is what will fill in the gaps
            puts "gg = #{gg}"
            gg.permutation do |dp|
              dpp = dp.zip(perm).flatten.compact
              puts "dpp = #{dpp.inspect}"
              next unless last.find(dpp[-1]) && dpp[0] != 0
              test = dpp.join.to_i
              next if hits[test]
              if test.prime?
                d_found += 1
                d_sum += test
                hits[test] = true
              end
            end
          end
        end
      end
      if d_found > 0
        total += d_sum
        puts "M(#{num_digits},#{digit})=#{digit_length} " +
          "N(#{num_digits},#{digit})=#{d_found} " +
          "S(#{num_digits},#{digit})=#{d_sum}"
        break 
      end
    end
  end
  total
end


if __FILE__ == $0
  p problem_110(4)
end

