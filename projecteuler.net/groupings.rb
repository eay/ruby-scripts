class String
  # Return an array of the index that the character can be found at
  def indexes(c)
    ret = []
    offset = 0
    while i = self.index(c,offset)
      ret << i
      offset = i + 1
    end
    ret
  end
end


class Array
  # Return the array with element in the passed array removed, but only
  # once
  # [1,1,2,3] ^ [1,2,3] => [1]
  def remove!(a)
    a.each do |e|
      if i = self.index(e)
        self.delete_at(i)
      end
    end
    self
  end

  def remove(a)
    self.dup.remove!(a)
  end
end

class Integer
  def palindrome?
    s = self.to_s
    # len = s.length/2
    # s[0,len] == s[-len,len].reverse
    s == s.reverse
  end

  # return all groupings of n elements
  # If n is 4,
  # [1,1,1,1]
  # [2,1,1]
  # [3,1]
  # [4]
  # [2,2]
  def groupings_old
    start = [[1]]
    (2..self).each do |n|
      r = []
      # p "in = > #{start.inspect}"
      start.map do |a|
        b = a.dup
        b.each_index do |i|
          if b.length == 1
            c = b.dup
            c[0] += 1
            r << c
          end
          if b[i+1]
            if b[i] > b[i+1]
              c = b.dup
              c[i+1] += 1
              r << c
            end
          else
            b << 1
            r << b.dup
            break
          end
        end
      end
      start = r
    end
    # We get some duplicates
    start.uniq
  end

  # How many combinations of the various lengths can be used to
  # make up the passed length.
  # self is the length, sizes is an array of 'tile' sizes
  def tiling(sizes,cache = {})
    if r = cache[self]
      r
    else
      ret = 0
      sizes.each do |s|
        next if s > self
        if self == s
          ret += 1
          next
        else
          ret += (self - s).tiling(sizes,cache)
        end
      end
      cache[self] = ret
      ret
    end
  end

  # New version, does yields, much more efficent, good to use
  # recursion :-).  yield must return true or we bail.
  def groupings
    solve = lambda do |a,off,max|
      while a[off] < max && (a.length-off) >= 2 
        a[off] += a.pop
        return unless yield a.dup
        solve.call(a.dup,off+1,a[off]) if a.length - off > 1
      end
    end

    start = [1] * self
    yield start.dup
    solve.call(start, 0, self-1) if self > 1
  end

  # Return the fractional sequence for square root.  The initial
  # integer is not present
  def sqrt_seq
    sqrt = Math.sqrt(self.to_f).floor.to_i
    top,bot = 1,-sqrt
    out = []
    loop do
      new_top = -bot
      new_bot = (self - (bot * bot)) / top
      break nil if new_bot == 0
      digit = (new_top + sqrt) / new_bot
      new_top -= digit * new_bot
      out << digit
      top,bot = new_bot,new_top
      return out if top == 1 && bot == -sqrt
    end
  end

  # If num is given, return the fraction after that number of
  # interations.  Yields each resolution of the fraction.
  # Always return [top,bottom]
  def sqrt_frac(num = nil,&block)
    work = lambda do |start,seq,finish|
      ltop,lbot,top,bot = 1, 0, start, 1
      seq.cycle do |v|
        v = v.call if v.is_a? Proc
        ltop,lbot,top,bot = top,bot, ltop + top * v, lbot + bot * v
        if block
          return [top,bot] if block.call(top,bot)
        else
          return [top,bot] if (finish -= 1) <= 1
        end
      end
    end
    r = self.sqrt_seq
    return nil unless r
    num ||= r.length
    work.call(Math.sqrt(self).to_i,r,num)
  end

  # decimal (base 10) sqrt, returns [numerator,decimal1, decimal2,...] given
  # the whole number and decimal parts
  # http://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Digit_by_digit_calculation
  def sqrt_digits(digits = 10)
    num = self.to_s
    num = "0" + num if num.length.odd?
#    dec = dec.to_s
#    dec += "0" if dec.length.odd?
#    pairs = (num + dec)
    pairs = num
    pairs = pairs.split(//).each_slice(2).map {|a,b| a.to_i * 10 + b.to_i }

    p = 0
    c = 0
    len = 0
    begin
      c = c * 100 + (pairs.shift || 0)
      if p == 0
        x,y = 1,1
      else
        x = c / (20 * p)
        if (y = (20*p+x)*x) > c
          while (yy = (20*p+(x-1))*(x-1)) > c
            x -= 1
            y = yy
          end
        else
          while (yy = (20*p+(x+1))*(x+1)) < c
            x += 1
            y = yy
          end
        end
      end
      p = p * 10 + x
      len += 1
      c -= y
      break if len >= digits
    end until c == 0 && pairs.length == 0
    r = p.to_s
    n = r[0,num.length/2].to_i
    d = r[num.length/2,r.length].gsub(/0+$/,"").split(//).map(&:to_i)
    d.unshift n
  end

end

if __FILE__ == $0
  2.sqrt_digits
end
