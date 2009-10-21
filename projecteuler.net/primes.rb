class Primes
  include Enumerable

  def initialize(max)
    unless @max
      @max = 3
      @sieve = Array.new
      @sieve[0] = false
      @sieve[1] = true
    end

    if max > @max
      m = @max
      @max = max
      (m/2).upto(max/2) {|i| @sieve[i] = true }
      2.upto(max) do |p|
        next unless self[p]
        (p+p).step(max,p) do |i|
          @sieve[i/2] = false unless i.even?
        end
      end
      @max = max
    end
  end

  def each
    yield 2
    @sieve.each_index do |i|
      yield i*2+1 if @sieve[i]
    end
  end

  def [](num)
    initialize(num+num) if num > @max
    num.odd? && @sieve[num/2]
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

  def self.each
    @@primes.each do |p|
      yield p
    end
  end

  def self.prime?(num)
    @@primes[num]
  end

  def self.upto(num)
    @@primes.prime?(num)
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

  def factors(num)
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

if __FILE__ == $0
  q = Primes.new(2_000)
  p q.factors(10)
end
