class Polynomial
  attr_reader :terms

  # Pass an array of terms, the [z,y,x,w] values of polynomials of the form
  # w*(n**3) + x*(n**2) + y*n + z.  The array index is the power of the n
  # value multiplied by the term
  def initialize(*terms)
    @terms = Array.new(0)
    @terms = terms.flatten.dup
  end

  def +(p)
    raise "Need to add a polynomial" unless self.class === p
    self.class.new(operate(p.terms,&:+))
  end

  def -(p)
    raise "Need to add a polynomial" unless self.class === p
    self.class.new(operate(p.terms,&:-))
  end

  def *(p)
    raise "Need to add a polynomial" unless Integer === p
    self.class.new(operate([p] * terms.length,&:"*"))
  end

  def /(p)
    raise "Need to add a polynomial" unless Integer === p
    ret = operate([p] * terms.length) do |a,b|
      r = a / b
      raise "non-integral division" if r * b != a
      r
    end
    self.class.new ret
  end

  # Evaluate the polynomial for term 'n'
  def evaluate(n)
    r = 0
    @terms.each_with_index do |m,i|
      r += m * n**i
    end
    r
  end
  alias f evaluate

  # print a reasable version of the polynomial
  def to_s
    r = ""
    (@terms.length-1).downto(0) do |i|
      m = @terms[i]
      next unless m && m != 0
      case m
      when -1
        sign,m = "-",nil
      when m < 0
        sign,m = "-","#{m.abs.to_s}"
      when 1
        sign,m = "+",nil
      else # m > 0
        sign,m = "+","#{m.abs.to_s}"
      end
      r += " #{sign} " unless r == "" && sign == "+"
      if i == 0
        r += m if m
      elsif i == 1
        r += "#{m}*n" if m
      else
        r += "n^#{i}"
      end
    end
    r.strip
  end

  # This does not work for non-integer solutions, I belive this is called
  # Neville's algorithm
  # Also look at Lagrange polynomials
  def self.optimum_solution(*kval)
    kval.flatten!
    return new(kval) if kval.length == 1
#    puts "k_len = #{kval.length}"
    pn = Array.new(kval.length) do |i|
      n = [kval[i]]
      0.upto(kval.length-1) do |power|
        n << (i+1) ** power
      end
      n
    end

    eqn = []
    loop do
      # Get the first set of values and remove the top term
      eqn << pn.map {|a| a.dup }
      p0 = pn.shift
      top = p0.rindex {|v| v.abs > 0}
      break unless top && top > 1
      p0_mul = p0[top]

      # Index 0 is the kval
      pn.each_with_index do |p,i|
        p_mul = p[top]
        p.each_index do |j|
          p[j] = p[j] * p0_mul - p0[j] * p_mul
        end
      end
    end

#    eqn.each {|e| puts "eqn #{e.inspect}" }
    #  We now have the solution for the first term and can work our way back
    #  up 'eqn', also checking that the answers are valid
    index = 1
    ans = []
    eqn.reverse.each do |sols|
      s = sols.first
#      puts "--#{s.inspect}"
      ans.each_with_index do |n,i|
        s[0] -= s[i+1]*n
        s[i+1] = 0
      end
#      puts s.inspect
      ans[index-1] = s[0] / s[index]
      index += 1
    end
    ans.pop while ans.last == 0
#    puts "ans = #{ans.inspect}"
    new ans
  end

  private

  # Apply the reduce operation with block on pair of polynomials
  def operate(b,&block)
    a = self.terms
    a,b = b,a if a.length < b.length
    b += [0] * (a.length - b.length) if a.length > b.length
    puts a.inspect
    puts b.inspect
    a.zip(b).map {|v| v.reduce(&block) }
  end
end
