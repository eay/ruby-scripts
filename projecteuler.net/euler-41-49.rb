#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require_relative 'primes'

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
    r = work.my_permutate do |a|
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

def problem_42
  triangles = 50.times.reduce([0]) {|a,n|
    a << a.last + n }.reduce({}) {|h,w| h[w] = true; h }

  # Load file,
  # remove "
  # split on ,
  # convert chars to a single number
  # select triangle words
  # number of them
  ret = open("words.txt").read.tr('"','').split(/,/).map { |w|
    w.bytes.reduce(0) {|a,c| a + c - 64}
  }.select {|n| triangles[n]}.length
#  p w
end

def problem_43
  nums = [2,3,5,7,11,13,17].map do |p|
    (12..987).map do |n|
      ns = n.to_s.split(//)
      ns[0,0] = "0" if ns.length == 2 # Never 1
      case
      when n % p != 0 then nil
      when ns.length == ns.uniq.length then ns
      else nil
      end
    end.compact
  end
  # nums is now 7 arrays of arrays that contain 3 pandigital divisable
  # 'numbers'.  They are actually chars.
  hits = []
  doit = lambda do |n_off,n,nums|
    if nums.length == 0 
      hits << ((%w{0 1 2 3 4 5 6 7 8 9} - n) + n).join.to_i
      return
    end
    nums.first.each do |nn|
      if n[n_off] == nn[0] && n[n_off+1] == nn[1]
        n1 = n + [nn[2]]
        next if n1.uniq.length != n1.length
        doit.call(n_off+1,n1,nums[1,10])
      end
    end
  end

  nums.first.each do |na|
    doit.call(1,na,nums[1,10])
  end
  hits.reduce(&:+)
end

# For a Pentagonal number, given by the formula Pn = n(3n-1)/2
# (Pn + Pn1) - (Pn - Pn1) == 2*Pn
# (Pn + Pn9) - (Pn - Pn9) == 2*Pn
# The distance to the upper term is not relevent.  So we need to find
# 2 Pentagonal numbers that are 2*Pn apart.
# sqrt(n * 2 /3).ceil return the closest (up) pantagonal number value.
# A back check will confirm if it is a true pantagonal number.
#
# P1020, P2167 => -term is P1912 and +term is P2395
def problem_44
  max = 10_000
  max_d = 1200
  pent = lambda {|n| n*(3*n - 1)/2 }

#  n2p={}
#  p2n={}
#  (0..max).each do |i|
#    p = pent.call(i)
#    n2p[i] = p
#    p2n[p] = i
#    puts i
#  end

  is_pent = lambda do |n|
    pent.call(Math.sqrt(n.to_f * 2 / 3).ceil) == n
  end
  npent = lambda {|n,d| pent.call(n+d) - pent.call(n) }
  ppent = lambda {|n,d| pent.call(n+d) + pent.call(n) }
  pdiff = lambda {|n,d| ppent.call(n,d) - npent.call(n,d) }

  m10 = 10_000
  (1..(max - max_d)).each do |i|
    puts (i+1) if (i+1) % m10 == 0
    p1 = pent.call(i)
    ((i+1)..(i+max_d)).each do |j|
      p2 = pent.call(j)
      if is_pent.call(p2 - p1) && is_pent.call(p2 + p1)
        #puts "BINGO + #{i} #{j} D = #{j - i}" 
        return(p2-p1)
      end
                                               
    end
  end
end

def problem_45
  nT = lambda {|n| n*(n+1)/2 }
  nP = lambda {|n| n*(3*n-1)/2 }
  nH = lambda {|n| n*(2*n-1) }

  t,p,h = 2,2,2
  puts "#{t} #{p} #{h}"
  tn,pn,hn = nT.call(t),nP.call(p),nH.call(h)
  loop do
    while tn != pn || pn != hn do
      while pn < hn
        p += 1
        pn = nP.call(p)
      end
      while tn < pn
        t += 1
        tn = nT.call(t)
      end
      while hn < tn
        h += 1
        hn = nH.call(h)
      end
    end
    puts "#{t}(#{tn}) #{p}(#{hn}) #{h}(#{hn})"
    return(tn) if t > 285 
    t += 1
    tn = nT.call(t)
  end
end

def problem_46
  sqn = 2
  sq = 4
  sql = [2]

  n = 7
  loop do
    n += 2
    next if n.prime?
    while 2*sq < n
      sql << 2*sq
      sqn += 1
      sq = sqn**2
    end
#    puts "#{n} #{sql}"
    ok = false
    sql.each do |s|
      if (n - s).prime?
        ok = true
        break;
      end
    end
    return n unless ok
  end
end

def problem_47
  num = 4
  count,n = 0,3
  loop do
    if n.factors.uniq.length == num
      count += 1
      break if count == num
    else
      count = 0
    end
    n += 1
  end
  n + 1 - num
end

def problem_48
  (1..1_000).reduce(0) {|a,i| a + i**i }.to_s[-10,10]
end

def problem_49
  nums = Primes.upto(9999).select {|p| p >= 1000}
  freq = {}
  nums.each do |p|
   i = p.to_s.split(//).sort.join.to_i
   freq[i] ||= []
   freq[i] << p
  end
  freq.each_pair do |k,v|
    next unless v.length >= 3
    v.sort!
    (v.length - 2).times do |offset|
      v.permutation(3).map(&:sort).uniq.each do |v|
        if (v[2] - v[1]) == (v[1] - v[0])
          if v[0] != 1487
            return v.map(&:to_s).join.to_i
          end
        end
      end
    end
  end
  nil
end

if __FILE__ == $0
  p problem_49
end

