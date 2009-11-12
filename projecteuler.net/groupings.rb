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

  # New version, does yields, much more efficent, good to use
  # recursion :-)
  def groupings
    solve = lambda do |a,off,max|
      if (a.length - off) > 1
        while a[off] < max && (a.length-off) >= 2 
          a[off] += a.pop
          yield a
          solve.call(a.dup,off+1,a[off])
        end
      end
    end

    start = [1] * self
    yield start
    solve.call(start, 0, self-1)
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
end



if __FILE__ == $0
  7.groupings.each do |a|
    p a
  end
end
