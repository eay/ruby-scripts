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
    n = 1
    loop do
      yield n*2+1 if @sieve[n]
      n += 1
      initialize(@sieve.length * 2 * 2) if n == @sieve.length
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

  def self.factors_old(num)
    @@primes.factors_old(num)
  end

  def self.each
    @@primes.each do |p|
      yield p
    end
  end

  def self.prime?(num)
    if num < 100_000
      @@primes[num]
    else
      num.factors.length == 1
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

  private
  def check_sieve_size(num)
    if @max <= Math.sqrt(num).to_i
      # puts "sieve is not large enough, regenerating"
      initialize(num)
    end
  end
end

class Integer
  def factorial
    (1..self).reduce(1) {|a,n| a*n}
  end

  def prime?
    Primes.prime?(self)
  end

  def factors
    Primes.factors(self)
  end

  def factors_old
    Primes.factors_old(self)
  end

  # Return all the divisors for the number
  def divisors
    fac = Primes.factors(self)
    div = {1 => true}
    (1..fac.length).each do |n|
      fac.combination(n) do |a|
        div[a.reduce(&:*)] = true
      end
    end
    div.keys.sort
  end

  def sum_of_divisors
    divisors.reduce(-self,&:+)
  end
end

class Array
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
