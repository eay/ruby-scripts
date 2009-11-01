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

module Problem54
  class Card
    attr_reader :value, :suit

    Suit =   { "H" =>  3, "D" =>  2, "C" =>  1, "S" =>  0}
    Card_value = { "T" => 10, "J" => 11, "Q" => 12, "K" => 13, "A" => 14}
    (1..9).each {|i| Card_value[i.to_s] = i }

    def initialize(card)
      raise "Invalue card #{card}" unless card =~ /^(.+)(.)$/
      @value = Card_value[$1]
      raise "Invalue card value #{card}" unless @value
      @suit = Suit[$2]
      raise "Invalue card suit #{card}" unless @suit
    end

    def <=>(c)
      ((i = c.value <=> @value) == 0) ? c.suit <=> @suit : i
    end

    def to_s
      sprintf "%d-%d",@value,@suit
    end
  end

  class Hand
    attr_reader :cards, :value

    # 100 High Card: Highest value card.
    # 200 One Pair: Two cards of the same value.
    # 300 Two Pairs: Two different pairs.
    # 400 Three of a Kind: Three cards of the same value.
    # 500 Straight: All cards are consecutive values.
    # 600 Flush: All cards of the same suit.
    # 700 Full House: Three of a kind and a pair.
    # 800 Four of a Kind: Four cards of the same value.
    # 900 Straight Flush: All cards are consecutive values of same suit.
    # 900 Royal Flush: Ten, Jack, Queen, King, Ace, in same suit.
    def initialize(cards)
      raise "Invalid hand size - #{cards.length}" unless cards.length == 5
      @cards = cards.map {|c| Card.new(c)}.sort
      @by_value = {}
      @by_suit = {}
      @cards.each do |c|
        @by_value[c.value] ||= []
        @by_suit[c.suit]   ||= []
        @by_value[c.value] << c
        @by_suit[c.suit]   << c
      end

      if @cards[4].value+1 == @cards[3].value &&
         @cards[3].value+1 == @cards[2].value &&
         @cards[2].value+1 == @cards[1].value &&
         @cards[1].value+1 == @cards[0].value
      end
      # Is it a straight
      @straight = true
      @cards.reduce do |p,c|
        if p.value != c.value + 1
          @straight = false
          break
        end
        c
      end
      value = [0]
      if @straight # Is it a straight
        value = [500, @cards.first.value]
      end
      # Is it a flush
      if @flush = @by_suit.find {|k,v| v.length == 5}
        if @straight
          value = [900, @cards.first.value]
        else
          value = [600, @cards.first.value]
        end
      end
      if value[0] < 700
        if (a = @by_value.find {|k,v| v.length == 3 }) &&
           (b = @by_value.find {|k,v| v.length == 2 })
          value = [700, a[0], b[0]]
        elsif a = @by_value.find {|k,v| v.length == 4 }
          value = [800, a[0]] # Is it 4 of a kind
        end
      end
      if value[0] < 500 && (a = @by_value.find {|k,v| v.length == 3 })
        value = [400, a[0]] # Is it 3 of a kind
      end
      if value[0] < 400 
        if (a = @by_value.select {|k,v| v.length == 2}).length > 0
          if a.length == 2
            hi,low = a[a.keys.max], a[a.keys.min]
            high = @cards - hi - low
            value = [300,hi.first.value, low.first.value, high.first.value]
          else
            pair = a[a.keys.first]
            high = (@cards - pair).first
            value = [200,pair.first.value, high.value]
          end
        else
          value = [100, @cards.first.value]
        end
      end
      @value = value
    end

    def <=>(b)
      @value <=> b.value
    end

    def to_s
      @cards.map(&:to_s).join(' ') + " value => #{value}"
    end
  end
end

def problem_54
  p1_win,p2_win,draw = 0,0,0
  open("poker.txt").each_line do |l|
    a = l.split
    p1 = Problem54::Hand.new(a[0,5]) 
    p2 = Problem54::Hand.new(a[5,5])
    result = p1 <=> p2
    p1_win += 1 if result == 1
  end
  p1_win
end

def problem_55
  l_nums = 0
  (1...10_000).each do |trial|
    n = trial
    50.times do |num|
      if (n += n.to_s.reverse.to_i).palindrome?
        l_nums -= 1
        puts "#{trial} -> #{n} #{num} good"
        break
      end
    end
    l_nums += 1
  end
  l_nums
end

def problem_56
  max = 0
  (90..99).each do |a| 
    (90..99).each do |b|
      max = [max,(a**b).to_s.split(//).map(&:to_i).reduce(&:+)].max
    end
  end
  max
end

def problem_67
  problem_18(open("triangle.txt").read.split(/\s+/).map(&:to_i))
end

if __FILE__ == $0
  p problem_56
end

