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
        sign,m = "-","#{m.abs.to_s}*"
      when 1
        sign,m = "+",nil
      when m > 0
        sign,m = "+","#{m.abs.to_s}*"
      end
      r += " #{sign} " unless r == "" && sign == "+"
      r += "#{m}*" if m
      r += "n**#{i}"
    end
    r.strip
  end

  def self.optimum_solution(*kval)
    return new(kval) if kval.length == 1
    puts "k_len = #{kval.length}"
    pn = Array.new(kval.length) do |i|
      n = []
      0.upto(kval.length-1) do |power|
        n << (i+1) ** power
      end
      n
    end

    puts pn.inspect

    ans = kval.dup
    loop do
      puts "do loop"
      # Get the first set of values and remove the top term
      puts "pn = #{pn.inspect}"
      p0 = pn.shift
      puts "p0 = #{p0.inspect}"
      puts "pn = #{pn.inspect}"
      a0 = ans.shift
      top = p0.rindex {|v| v.abs > 0}
      puts "top = #{top} a0 = #{a0}"
      break unless top && top > 0
      p0_mul = p0[top]
      puts "p0_mul = #{p0_mul}"

      new_pn = []
      pn.each_with_index do |p,i|
        p_mul = p[top]
        ans[i] = ans[i] * p0_mul - a0 * p_mul
        puts "p0_mul = #{p0_mul} p_mul = #{p_mul} ans = #{ans[i]}"
        p.each_index do |j|
          print "#{i} #{j}| #{p[j]} * #{p0_mul} - #{p0[j]} * #{p_mul} => "
          p[j] = p[j] * p0_mul - p0[j] * p_mul
          puts p[j]
        end
        puts " #{ans[i]} == #{p.inspect}"
        new_pn << p
      end

      puts "---"
      puts pn.inspect
      puts ans.inspect
    end
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
