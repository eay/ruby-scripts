class Point
  attr_reader :x, :y

  def initialize(x,y)
    @x,@y = x,y
  end

  Origin = self.new(0.0,0.0)

  # distance between 2 points, floating point returned
  def length(p)
    Math.sqrt((@x - p.x)**2 + (@y - p.y)**2)
  end

  # Angle in radian between the line and the +ve x axis, -π < ret ≤ π
  def angle(p)
    x = p.x - @x
    y = p.y - @y
    return nil if y == 0 && x == 0
    Math.atan2(y,x)
  end

  def +(p)
    Point.new(@x + p.x, @y + p.y)
  end

  def -(p)
    Point.new(@x - p.x, @y - p.y)
  end

  # Is p1 between the lines self/p0 and self/p2
  def between(p0,p1,p2)
    a0 = self.angle(p0).degrees
    a1 = self.angle(p1).degrees
    a2 = self.angle(p2).degrees
    a0,a2 = [a0,a2].min, [a0,a2].max
    r = (a0..a2).include? a1
    if a0 + 180.0 < a2 # outside of a0..a2
      !r 
    else
      r
    end
  end
end

class Float
  # Convert radians to degrees
  def degrees
    ret = 180.0 * self / Math::PI
    ret % 360.0
  end
end

if __FILE__ == $0
  puts "0 == #{Point::Origin.angle(Point.new(10,0)).degrees}"
  puts "45 == #{Point::Origin.angle(Point.new(10,10)).degrees}"
  puts "90 == #{Point::Origin.angle(Point.new(0,10)).degrees}"
  puts "135 == #{Point::Origin.angle(Point.new(-10,10)).degrees}"
  puts "180 == #{Point::Origin.angle(Point.new(-10,0)).degrees}"
  puts "225 == #{Point::Origin.angle(Point.new(-10,-10)).degrees}"
  puts "270 == #{Point::Origin.angle(Point.new(0,-10)).degrees}"
  puts "315 == #{Point::Origin.angle(Point.new(10,-10)).degrees}"

  puts Point::Origin.between(Point.new(10,10),Point.new(5,4),Point.new(10,0))
  puts Point::Origin.between(Point.new(10,10),Point.new(5,6),Point.new(10,0))
  puts Point::Origin.between(Point.new(-10,10),Point.new(5,4),Point.new(10,0))
  puts Point::Origin.between(Point.new(-10,-10),Point.new(5,6),Point.new(10,0))
end
