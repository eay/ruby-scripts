class Polynomial
  attr_reader :terms

  # Pass an array of terms, the [z,y,x,w] values of polynomials of the form
  # w*(n**3) + x*(n**2) + y*n + z.  The array index is the power of the n
  # value multiplied by the term
  def initialize(*terms)
    @terms = terms.flatten.dup
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
    r
  end

end
