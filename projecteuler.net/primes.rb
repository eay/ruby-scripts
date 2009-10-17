class Primes
  include Enumerable

  def initialize(max)
    unless @max
      @max = 3
      @sieve = Array.new
      @sieve[0] = false
      @sieve[1] = true
    end

    if @max < max
      m = @max
      @max = max
      ((m+1)/2).upto((max+1)/2) {|i| @sieve[i] = true }
      (m+1).upto(max) do |p|
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
    raise "number too big #{num} vs #{@max}" if num > @max
    num.odd? && @sieve[num/2]
  end

  def to_s
    out = ""
    @sieve.each_index {|i| out << "#{i*2+1} " if @sieve[i]}
    out.chop
  end

  @@primes = nil
  def self.factors(num)
    @@primes ||= Primes.new(num)
    @@primes.factors(num)
  end

  def self.each
    @@primes ||= Primes.new(10_000)
    @@primes.each { |p| yield p }
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

  # Return all the divisors for the number
  def self.divisors(num)
    fac = self.factors(num)
    nfac = fac.reduce(Hash.new(0)) {|h,v| h[v] += 1; h }
    # For each
    fac.length.times
    p fac
    p nfac
  end

  # Return arrays made of n of a's elements
  def self.div_combinations(a,n = a.length)
    puts "Enter #{n}"
    p a
    ret = []
    if n == 1
      ret = a.dup.indexmap do |v|
      end 
    else
      a.length.times do |i|
        b = a.dup
        b[i,1] = nil # delete entry
        
        r = div_combinations(b,n-1)
        puts "r => #{r.inspect}"
        ret << r
      end
    end
    ret
  end

  private
  def check_sieve_size(num)
    if @max <= Math.sqrt(num).to_i
      # puts "sieve is not large enough, regenerating"
      initialize(num)
    end
  end
end

if __FILE__ == $0
  q = Primes.new(2_000)
  p q.factors(10)
end
