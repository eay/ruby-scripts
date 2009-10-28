class Integer

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
end


if __FILE__ == $0
  7.groupings.each do |a|
    p a
  end
end
