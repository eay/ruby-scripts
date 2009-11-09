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
  # If n in 4,
  # [1,1,1,1]
  # [2,1,1]
  # [3,1]
  # [4]
  # [2,2]
  def groupings
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

  def sqrt_seq(n)
    sqrt = Math.sqrt(n.to_f).floor.to_i
    top,bot = 1,-sqrt
    out = []
    loop do
      new_top = -bot
      new_bot = (n - (bot * bot)) / top
      break nil if new_bot == 0
      digit = (new_top + sqrt) / new_bot
      new_top -= digit * new_bot
      out << digit
      top,bot = new_bot,new_top
      return out if top == 1 && bot == -sqrt
    end
  end
end



if __FILE__ == $0
  7.groupings.each do |a|
    p a
  end
end
