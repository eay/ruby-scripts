#!/usr/bin/env ruby1.9
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

require 'rational'
# Use ruby1.9 or it is very very slow
def problem_57a
  root2 = lambda do |depth|
    if depth == 0
      Rational(1,2) 
    else
      Rational(1,(root2.call(depth - 1) + 2))
    end
  end
  ret = 0
  1000.times do |n|
    r = root2.call(n) + 1
    ret += 1 if r.numerator.to_s.length > r.denominator.to_s.length
  end
  ret
end

# This is the correct way to do things
def problem_57
  ret,n,d = 0,1,1
  1000.times do |i|
    n,d = (n+2*d),(n+d)
    ret += 1 if n.to_s.length > d.to_s.length
  end
  ret
end

def problem_58
  side = 1
  d = [1,1,1,1]
  total,primes = 1,0
  loop do
    d[0] = d[3] + side + 1
    d[1] = d[0] + side + 1
    d[2] = d[1] + side + 1
    d[3] = d[2] + side + 1
    side += 2
    total += 4
    #puts "#{primes}/#{total} #{d.inspect}"
#    printf "#{side} %.2f\n", primes.to_f/total.to_f * 100.0
    (0..2).each do |i|
      primes += 1 if d[i].prime?
    end
    return(side) if primes * 10 < total
  end

end

def problem_59
  chars = open("cipher1.txt").read.chomp.split(/,/).map(&:to_i)
  ascii = 32 .. 126
  s = chars.each_slice(3).to_a
  g = s[0].zip(*s[1,s.length-1]).map(&:compact) # Make 3 arrays of the bytes
  keys = []
  g.each_index do |i|
    wa = g[i]
    max_sp,k = 0,0
    ('a'..'z').each do |key|
      i = key.bytes.first
      good = true
      wa.each do |c|
        unless ascii === (c ^ i)
          good = false
          break
        end
      end
      if good
        # Save the space and 'e' frequency
        sp = wa.select {|c| c == (32 ^ i)}.length
        if sp > max_sp
          k = i
          max_sp = sp
        end
      end
    end
    keys << k
  end
  out = []
  s.each do |a0,a1,a2|
    out << (a0 ^ keys[0])
    out << (a1 ^ keys[1]) if a1
    out << (a2 ^ keys[2]) if a2
  end
  puts  out.map(&:chr).join
  puts keys.map(&:chr).join
  out.reduce(&:+)
end

# 26033 ["13", "5197", "5701", "6733", "8389"]
# No array, but slower than problem_60a
# This caused me lots of problems.  The main issue was given 2 primes that
# pair, how do we check their common pairings?  In this case I simply
# make sure they have more than num_cut common elements, then re-check
# all of them (all permutations).  I'm not totaly sure if the case can
# occur where the 2 numbers share 6 elements but only 5 are good for
# the solution.  The permutate code would fail in this case.
def problem_60
  num_cut = 5
# simple
  pairs = {}
  seen_primes = []
  num_primes = 0
  last = start = Time.now
  Primes.each do |p|
    next if p == 2
    b = p.to_s
    seen_primes.each_index do |sp_i|
      sp = seen_primes[sp_i]
      a = sp.to_s
      ai,bi = a.to_i,b.to_i
      ab = (a + b).to_i
      ba = (b + a).to_i

      if ba.prime? && ab.prime?
        # We have a pair that works both ways so add the peer to each prime
        pairs[ai] = aa = ((pairs[ai] || []) << bi).uniq
        pairs[bi] = bb = ((pairs[bi] || []) << ai).uniq
        next unless pairs[bi].length >= num_cut - 1 # bi is biggest of pair

        check = ([ai] + aa) & ([bi] + bb)
        if check.length >= num_cut
          puts "Try #{check.inspect}"
          perm = check.permutation(2).to_a
          new = perm.select do |x,y|
            (x.to_s + y.to_s).to_i.prime? && (x.to_s + y.to_s).to_i.prime?
          end
          if new.length == perm.length
            n = new.flatten.uniq
            sum = n.reduce(&:+)
            puts "#{n.inspect} ***  #{sum}"
            return sum
          end
        end
      end
    end
    seen_primes << p
  end
  nil
end

# 26033 ["13", "5197", "5701", "6733", "8389"]
def problem_60a
  prime_check = lambda do |a,b|
    (a + b).to_i.prime? && (b + a).to_i.prime?
  end

  find_match = lambda do |a,k|
    r = a.select {|p| k != p && prime_check.call(k,p) }
  end

  primes = Primes.upto(10_000).map(&:to_s)
  primes.delete("2")

  hit = {}

  primes.each do |p1|
    p1a = find_match.call(primes,p1)
    p1a.each do |p2|
      p2a = find_match.call(p1a,p2)
      p2a.each do |p3|
        p3a = find_match.call(p2a,p2)
        p3a.each do |p3|
          p4a = find_match.call(p3a,p3)
          p4a.each do |p4|
            p5a = find_match.call(p4a,p4)
            if p5a.length > 0
              p5a.each do |p5|
                a = [p1,p2,p3,p4,p5]
                sum = a.map(&:to_i).reduce(&:+)
                unless hit[sum]
                  puts "#{sum} #{a.inspect}"
                else
                  hit[sum] = true
                end
                return sum
              end
            end
          end
        end
      end
    end
  end
end

def problem_61
  # Functions for Triangle to Octagonal numbers
  funcs = (3..8).map {|x| lambda {|n| n*((x-2)*n+4-x)/2 }}

  # Generate all 4 digits numbers of each type
  numbers = funcs.map do |l|
    ret = []
    10000.times do |i|
      n = l.call(i)
      next if n < 1000
      break if n >= 10_000
      ret << n.to_s
    end
    ret
  end
  # Now we do the search, numbers is the array of the different types of
  # numbers.  We need to find a cycle where when we run out of numbers,
  # we are back at the start
  f = Proc.new do |numbers,f_index,num,nums|
    numbers += [num]
#    puts "#{numbers.first} => #{num} #{nums.length}"
    # First, which arrays have matches

    nums.each_index do |index|
      next_index = f_index + [index]
      next_nums = nums.dup
      me = next_nums.delete_at(index)
      me.grep(/^#{num[2,2]}/).each do |hit| # each mach
#        puts "#{num} -> hit => #{hit}"
        if nums.length == 1
          if numbers.first[0,2] == hit[2,2]
            numbers += [ hit ]
            puts numbers.inspect
            puts "Array index for each round => #{next_index.inspect}"
            return numbers.map(&:to_i).reduce(&:+)
          end
        else
          f.call(numbers,next_index,hit,next_nums)
        end
      end
    end
  end

  numbers.pop.each do |n|
    f.call([],[0],n,numbers)
  end
  # Should not get here
  "miss"
end

def problem_62
  # NOTE: their may be another number with a smaller first permutation,
  # but that check was not needed for 5 numbers
  sol = nil
  cube_perms = {}
  n = 300
  loop do
    q = n ** 3
    qs = q.to_s.split(//).sort.join
    cube_perms[qs] ||= []
    cube_perms[qs] << n
    if cube_perms[qs].length >= 5
      puts cube_perms[qs].inspect
      qsf = cube_perms[qs].first 
      unless sol 
        sol = qsf
      else # We have a solution, see if this is smaller
        if sol > qsf
          sol = qsf
        elsif sol.to_s.length < qsf.to_s.length
          return sol ** 3
        end
      end
    end
    n += 1
  end
end

def problem_63
  count = 0
  (1..100).each do |n|
    100.times do |x|
      nx = n ** x
      nxl = nx.to_s.length
      #puts "#{n} ** #{x} => #{nxl}" if nxl == x
      count += 1 if nxl == x
    end
  end
  count
end

def problem_64
  sqrt_seq = lambda do |n|
    sqrt = Math.sqrt(n.to_f).floor.to_i
    top,bot = 1,-sqrt
    out = []
    loop do
      new_top = -bot
      new_bot = (n - (bot * bot)) / top
      break nil if new_bot == 0
      digit = (new_top + sqrt) / new_bot
      new_top -= digit * new_bot
      out << digit
      top,bot = new_bot,new_top
      break out if top == 1 && bot == -sqrt
    end
  end

  odd,max = 0,0
  (2..10_000).each do |num|
    next unless r = sqrt_seq.call(num)
    puts "#{num} => #{r.length}"
    max = [max,r.length].max
    odd += 1 if r.length.odd?
  end
  puts "max => #{max}"
  odd
end

def problem_65
  work = lambda do |start,seq,finish|
    ltop,lbot,top,bot = 1, 0, start, 1
    seq.cycle do |v|
      v = v.call if v.is_a? Proc
      ltop,lbot,top,bot = top,bot, ltop + top * v, lbot + bot * v
      # puts "#{top} / #{bot}"
      return [top,bot] if (finish -= 1) == 1
    end
  end
  n = 0
  n_val = lambda { n = n + 2 }
  top,bot = work.call(2,[1,n_val,1],100)
  top.to_s.split(//).map(&:to_i).reduce(&:+)
end

def problem_67
  problem_18(open("triangle.txt").read.split(/\s+/).map(&:to_i))
end

if __FILE__ == $0
  p problem_65
end

