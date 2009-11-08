#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require 'primes.rb'
require 'groupings.rb'

class Problem68
  attr_accessor :value
  def to_s
    @value.to_s
  end
end

def problem_68
  p = 10.times.map { Problem68.new }
  lines = [
    [p[0],p[1],p[2]],
    [p[3],p[2],p[4]],
    [p[5],p[4],p[6]],
    [p[7],p[6],p[8]],
    [p[9],p[8],p[1]]]

  ans = []
  # To avoid sorting, only need to search with the first value
  # being 10, 9 or 8.  THis makes it about 3 times faster
  (8..10).each do |j|
    pa = (1..10).to_a
    pa.delete(j)
    pa.permutation do |values|
      values.unshift j 
      p.each_index { |i| p[i].value = values[i] }
      sum = lines.first.reduce(0) {|a,v| a + v.value }
      lines[1,lines.length-1].each do |a|
        s = a.reduce(0) {|a,v| a + v.value }
        unless s == sum
          sum = nil
          break
        end
      end
      if sum
        min = lines.map {|l| l[0].value}.min
        start = lines.index {|l| l[0].value == min}
        print "#{start}: "
        res = lines[start,lines.length-start].map do |ll|
          ll.map(&:to_s).join
        end.join
        res += lines[0, start].map do |ll|
          ll.map(&:to_s).join
        end.join
        puts "#{sum} #{res}"
        ans << res if res.length == 16
      end
    end
  end
  ans.map(&:to_i).sort.last
end

if __FILE__ == $0
  p problem_68
end

