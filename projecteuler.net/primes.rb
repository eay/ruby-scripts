if RUBY_VERSION < "1.8.7"
  class Integer
    def even?
      self & 0x01 == 0
    end
    def odd?
      self & 0x01 == 1
    end
  end
end

require 'rational'

class Primes
  include Enumerable

  def initialize(max)
    unless @max
      @max = 3
      @upto = 1
      @sieve = Array.new
      @sieve[0] = false
      @sieve[1] = true
    end

    
    if max > @max
      upto = @upto
      while upto * upto < max
        upto *= 2
      end
      m = @max
      @max = upto*upto
#      puts "clear #{m/2}..#{@max/2}"
      (m/2).upto(@max/2) {|i| @sieve[i] = true }
      2.upto(upto) do |p|
        next unless self[p]
        (@upto/p*p).step(@max,p) do |i|
          next if i == p
          @sieve[i/2] = false unless i.even?
        end
      end
      @upto = upto
#      puts "max = #{@max} upto = #{@upto}"
    end
  end

  def each
    yield 2
    n = 3
    loop do
      yield n if n.prime?
      n += 2
    end
  end

  def [](num)
    initialize(num+num) if num > @max
    num == 2 || (num.odd? && @sieve[num/2])
  end

  alias prime? []

  def to_s
    out = ""
    @sieve.each_index {|i| out << "#{i*2+1} " if @sieve[i]}
    out.chop
  end

  @@primes = Primes.new(1000)

  def self.factors(num)
    @@primes.factors(num)
  end

  def self.first_factor(num)
    @@primes.first_factor(num)
  end

  def self.factors_old(num)
    @@primes.factors_old(num)
  end

  def self.each
    @@primes.each do |p|
      yield p
    end
  end

  def self.prime?(num)
    if num <= 100_000
      @@primes[num]
    else
      @@primes.prime_check_factors(num)
    end
  end

  def self.upto(num)
    if block_given?
      Primes.each do |p|
        break if p > num
        yield p
      end
    else
      ret = []
      (2..num).each do |n|
        ret << n if n.prime?
      end
      ret
    end
  end

  def factors_old(num)
    check_sieve_size(num)
    fac = []
    each do |p|
      return(fac) if p > num
      while num % p == 0
        fac << p
        num /= p
        return(fac) if num == 1
      end
    end
    # If we get to here there is a factor left that is > sqrt(num), so
    # it's matching element must be less
    fac << num
  end
  
  def factors(num)
    sq = Math.sqrt(num).to_i
    fac = []
    each do |p|
      if p > sq
        fac << num
        return(fac) 
      end
      while num % p == 0
        fac << p
        num /= p
        return(fac) if num == 1
      end
    end
    # If we get to here there is a factor left that is > sqrt(num), so
    # it's matching element must be less
    fac << num
  end

  def first_factor(num)
    sq = Math.sqrt(num).to_i
    each do |p|
      return p if num % p == 0 || p > sq
    end
    # We should never get here
  end

  # Check if a number is prime by trying to find factors.
  # This method only needs the primes upto sqrt(num).  So for big
  # primes, this is the way to go.
  def prime_check_factors(num)
    # The following line slows things down
    # return false if num.to_s.split(//).reduce(&:+) % 6 == 0
    sq = Math.sqrt(num).to_i
    each do |p|
      return false if num % p == 0
      return true if p >= sq
    end
  end

  private
  def check_sieve_size(num)
    if @max <= Math.sqrt(num).to_i
      # puts "sieve is not large enough, regenerating"
      initialize(num)
    end
  end
end

class Integer
  # Integer version of permutation
  def permutation(&block)
    rec = lambda do |n,d|
      if d.length == 1
        yield n*10 + d.first
      else
        n *= 10
        dd = d.dup
        old = dd.shift
        dd.length.times do |i|
          rec.call(n + old, dd)
          dd[i],old = old, dd[i]
        end
        rec.call(n + old, dd)
      end
    end

    rec.call(0, self.to_s.split(//).map(&:to_i))
    self
  end

  # Digits are neither incrementing or decrementing
  def bouncy?
    dl = self % 10
    n = self / 10
    dir = 0
    while n > 0
      #n,dn = n.divmod(10)
      dn = n % 10
      n = n / 10

      d = dl <=> dn
      case dir
      when -1
        return true if d == 1
      when 0
        dir = d
      when 1
        return true if d == -1
      end
      dl = dn
    end
    return false
  end

  def factorial
    (1..self).reduce(1) {|a,n| a*n}
  end

  def triangle
    self * (self+1) / 2
  end

  # Break a number into it's digits
  def to_digits
#    self.to_s.split(//)                       84sec
#    self.to_s.unpack("C*").map {|b| b - 48 }  26sec
#    self.to_s.bytes.map {|b| b - 48 }         29sec
#    The below code takes                      21sec
    r = []
    n = self
    while n > 0
      r << n % 10
      n /= 10
    end
    r.reverse
  end

  def prime?
    Primes.prime?(self)
  end

  def factors
    Primes.factors(self)
  end

  def first_factor
    Primes.first_factor(self)
  end

  def factors_old
    Primes.factors_old(self)
  end

  # Return all the divisors for the number
  def self.divisors(fac = Primes.factors(self))
    div = {1 => true}
    (1..fac.length).each do |n|
      fac.combination(n) do |a|
        div[a.reduce(&:*)] = true
      end
    end
    div.keys.sort
  end

  def divisors(fac = Primes.factors(self))
    self.class.divisors(Primes.factors(self))
  end

  def sum_of_divisors
    divisors.reduce(-self,&:+)
  end

  # Pass in the factors
  def self.sum_of_divisors(fac)
    sum = fac.reduce(1,&:"*")
    puts sum
    self.divisors(fac).reduce(-sum,&:+)
  end

  # Return an array of the sum of divisors upto 'n'
  def self.sum_of_divisors_upto(n)
    ret = Array.new(n+1,1)
    # for each number
    2.upto(n) do |i|
      # we iterate over it's multiples, adding it's value as the
      # number of additional divisors.  A kind of sieve.
      (i+i).step(n,i) do |j|
        ret[j] += i
      end
    end
    ret
  end

  # Return Euler's totient, or the number of number of positive integers
  # less than or equal to n that are co-prime.  The order of the number.
  # We can pass in the factors to speed things up
  def totient(*fact)
    fact = self.factors if fact.empty?
    n = self
    fact.uniq.each do |f|
      n = n*(f-1)/f
    end
    n
  end

  # Greatest common divisor
  def gcd(num)
    if num == 0
      self
    else
      num.gcd(self - num * (self/num))
    end
  end
  alias gcf gcd # aka greatest common factor
  alias hcf gcd # aka highest common factor

  # Least common multiple
  def lcm(num)
    (self * num).abs / gcd(num)
  end

  # least common divisor
  def lcd(num)
    gcd(num).first_factor
  end

  # Picked up the algorithm from 
  # http://en.wikipedia.org/wiki/Farey_sequence
  # It steps through all the reduced proper factions
  # between the 2 passed factions.  The denominator maximun is self.
  # Returns the number of elements, yields each point
  def farey(p1 = [0,1],p2 = [1,1])
    n = self
    # a,b is the start point, c,d needs to be the next point.
    a,b = p1
    # Make sure it is a reduce proper fraction.  We can do this with gcf,
    # but lets just use rational
    r = Rational(a,b)
    a,b = r.numerator,r.denominator
    # First, we get an approximation of the start point
    c,d = a*n/b,n
    if c * b == n
      # If we are an exact match, make the denominator one smaller,
      # just a little bit bigger
      d -= 1 
    else
      # else we are just under, so make the numerator one bigger
      c += 1
    end
    # Again, make sure the endpoint is a reduced proper fraction
    r = Rational(*p2)
    p2 = [r.numerator,r.denominator]
 
    count = 1
    yield [a,b] if block_given?
    while [a,b] != p2 # || c < n this exits at 1/1
      # Given 2 points, we determin the next one.
      # Given three points in sequence
      # [a,b] [c,d] [e,f]
      # [c,d] == [a+e,b+f]
      # [e,f] == [kc-a.kd-b] where k = (n+b)/d
      # I'm still not fully over the k calculation, but it works.
      # The k value does the 'reduced proper fraction' part.
      # For the new d value, we are doing (n+b)/d*d, so it is a multiple of d.
      # The new c is (n+b)/d*c, so the same .... thinking still....
      k = (n+b)/d
      a,b,c,d = c, d, k*c - a, k*d - b
      count += 1
      yield [a,b] if block_given?
    end
  count
  end

  def pentagonal
    self * (3 * self -1) / 2
  end

  def self.pentagonals
    i = 1
    loop do
      yield i.pentagonal
      i += 1
    end
  end

  def self.generalized_pentagonals
    i = 1
    loop do
      break unless yield i.pentagonal
      break unless yield((-i).pentagonal)
      i += 1
    end
  end

  # It is a simple algorithm, to count the number of possible piles we can
  # divide into.
  # p(n,k)
  #   return 1 if k == 1 || n == k
  #   return 0 if k > n
  #   return p(n-1,k-1) + p(n-k,k)
  #
  # sum = 0
  # 1..target do |n|
  #   sum += p(target,n)
  #
  #  The way to make it fast is to cache the return values from
  #  p(n,k).
  def partitions_a(cache = {})
    count = lambda do |n,k|
      s = "#{n} #{k}"
      if v = cache[s]
        return v
      end
      #puts "#{n} #{k}"
      return 1 if k == 1 || n == k
      return 0 if k > n
      r = count.call(n-1,k-1) + count.call(n-k,k)
      cache["#{n} #{k}"] = r
  #    puts "#{cache.length} => #{r}"
      r
    end
    (1..self).reduce(0) do |a,k|
      a + count.call(self,k)
    end
  end

  # A bit over 2 times faster, cache better
  # cache[n-k] if n <= k*2 
  # http://en.wikipedia.org/wiki/Partition_(number_theory)
  def partitions(cache = {})

    count = lambda do |n,k|
      return 1 if n == k || k == 1

      if n <= k*2
        s = n-k
      else
        s = "#{n} #{k}"
      end
      if v = cache[s]
        return v
      end

      if k == 2
        r = 1
      else
      #  puts "miss #{n-1} #{k-1}" unless cache["#{n-1} #{k-1}"]
        r = count.call(n-1,k-1)
      end
      r += count.call(n-k,k) unless k+k > n # Only call with n >= k

      cache[s] = r unless k == 2
      r
    end

    # Half the calls are cached
    r = (1..self).reduce(0) do |a,k|
      a + count.call(self,k)
    end

    sum = 0
    (1..(self/2)).each do |k|
      sum += 1 + count.call(self-k,k)
    end
    r
  end
end

class Array
  # return the number of possible ways that the passed array could be re-ordered.
  # [1, 2, 2, 2] => 4
  # [1, 2, 2, 3] => 12
  # [2, 2, 3, 3] => 6
  def permutations
    h = Hash.new(0)
    self.each { |i| h[i] += 1 }
    h.reduce(self.size.factorial) { |a,b| a /= b[1].factorial }
  end

  # yield with each possible ordering of the passed array.
  # We must be passed at least 2 elements.
  # The permutation is conducted starting with the last elements in the array
  def my_permutate
    if length == 2
      yield [self[0],self[1]]
      yield [self[1],self[0]]
    else
      b = dup
      c = b.shift
      self.each_index do |i|
        b.my_permutate do |r|
          yield [c] + r
        end
        b[i],c = c,b[i]
      end
    end
  end
end

if __FILE__ == $0
  q = Primes.new(2_000)
  p q.factors(10)
end
