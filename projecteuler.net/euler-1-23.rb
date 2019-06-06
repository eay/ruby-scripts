#!/usr/bin/env ruby
# Taken from http://projecteuler.net
require_relative './primes.rb'

# Problem 1
# Add all the natural numbers below one thousand that are multiples of 3 or 5
def problem_1
  (0...1000).select { |v| v % 3 == 0 || v % 5 == 0 }.reduce(&:+)
end

# Problem 2
# Find the sum of all the even-valued terms in the Fibonacci sequence
# which do not exceed four million.
def problem_2
  sum,p,f = 0,1,2
  while f < 4_000_000 do
    sum += f if f.even?
    f,p = f+p,f
  end
  sum
end

# Problem 3
# Find the largest prime factor of a composite number.
# This is overkill
def problem_3a(num = 600851475143, ret_factors = false)
  primes = lambda do |&block|
    n = 3
    primes = [2]
    is_prime = lambda {|v| !primes.find {|p| v % p == 0}}
    loop do
      if is_prime.call(n)
        primes << n
        block.call n
      end
      n += 2
    end
  end
  max = 0
  primes.call do |p|
    max = p if (num % p).zero?
    puts p
    return(max) if p*p >= num
  end
end

def problem_3(num = 600851475143, ret_factors = false)
  factors = []
  d = 1
  while num > 1
    d += 1
    while (num % d).zero?
      factors << d
      num /= d
    end
  end
  if ret_factors
    factors
  else
    factors.last
  end
end

def prime_factors(num)
  problem_3(num,true)
end

# Find the largest palindrome made from the product of two 3-digit numbers.
def problem_4(digits = 3)
  s = 10**digits - 1
  t = s/10 + 1
  s.downto(t) do |n|
    r = (n.to_s + n.to_s.reverse).to_i
    s.downto(t) do |div|
      break if (r / div) > s
      return(r) if (r % div).zero?
    end
  end
  return(0)
end

# What is the smallest number divisible by each of the numbers 1 to 20?
# We could just use a lcm function, but we can instead reuse problem_3
def problem_5(numbers = 20)
  facs = (2..numbers).reduce(Hash.new(0)) do |t,n|
    f  = prime_factors(n).reduce(Hash.new(0)) do |h,v|
      h[v] += 1
      h
    end
    t.merge(f) {|h,ov,nv| [ov,nv].max }
  end
  facs.reduce(1) do |a,v|
    a * v[0] ** v[1]
  end
end

# What is the difference between the sum of the squares and
# the square of the sums?
def problem_6(num = 100)
  (1..num).reduce {|a,n| a + n } ** 2 -
    (1..num).reduce {|a,n| a + n*n }
end

# we have two prime lists, the one we sieve against, and a list of primes
# that are still to big to worry about.
# sieve.last * primes.first need to be the >= n, so we move values from primes
# to sieve, but we add new primes to primes.
def primes(num = nil)
  primes = []
  if block_given?
    yield 2
    yield 3
    yield 5
    yield 7
  end
  n = 11
  sieve = [7]
  number = 4

  loop do
    if (n % 3) != 0 &&
       (n % 5) != 0 &&
       !sieve.find {|p| (n % p).zero? } # Non-prime
      primes << n
      while primes.first * sieve.last < n 
        sieve << primes.shift
      end
      yield n if block_given?
      number += 1
      return([2,3,5] + sieve + primes) if num && number >= num
    end
    n += 2
  end
end

# Find the 10001st prime.
def problem_7(num = 10001)
  i = 0
  primes do |p|
    i += 1
    return(p) if i == num
  end
end

# Discover the largest product of five consecutive digits in the
# 1000-digit number.
def problem_8
  numbers = "
    73167176531330624919225119674426574742355349194934
    96983520312774506326239578318016984801869478851843
    85861560789112949495459501737958331952853208805511
    12540698747158523863050715693290963295227443043557
    66896648950445244523161731856403098711121722383113
    62229893423380308135336276614282806444486645238749
    30358907296290491560440772390713810515859307960866
    70172427121883998797908792274921901699720888093776
    65727333001053367881220235421809751254540594752243
    52584907711670556013604839586446706324415722155397
    53697817977846174064955149290862569321978468622482
    83972241375657056057490261407972968652414535100474
    82166370484403199890008895243450658541227588666881
    16427171479924442928230863465674813919123162824586
    17866458359124566529476545682848912883142607690042
    24219022671055626321111109370544217506941658960408
    07198403850962455444362981230987879927244284909188
    84580156166097919133875499200524063689912560717606
    05886116467109405077541002256983155200055935729725
    71636269561882670428252483600823257530420752963450"
  numbers = numbers.gsub(/\s/m,"").split(//).map(&:to_i)
  numbers.each_cons(5).map {|a| p a; a.reduce(&:*) }.max
end

# Find the only Pythagorean triplet, {a, b, c}, for which a + b + c = 1000.
def problem_9(num = 1000)
  a_max = (num-2)/3
  2.upto(a_max) do |a|
    (a+1).upto(num - 2) do |b|
      c = num - a - b
      next if c < b
      if a*a + b*b == c*c
        puts "#{a} #{b} => #{c}"
        return a * b * c
      end
    end
  end
  raise "no solution"
end

# Calculate the sum of all the primes below two million.
def problem_10(num = 2_000_000)
  sum = 0
  primes do |p|
    return sum if p >= num
    sum += p
  end
  raise "no solution"
end

def problem_11(num = 5)
  grid = %w{
    08 02 22 97 38 15 00 40 00 75 04 05 07 78 52 12 50 77 91 08
    49 49 99 40 17 81 18 57 60 87 17 40 98 43 69 48 04 56 62 00
    81 49 31 73 55 79 14 29 93 71 40 67 53 88 30 03 49 13 36 65
    52 70 95 23 04 60 11 42 69 24 68 56 01 32 56 71 37 02 36 91
    22 31 16 71 51 67 63 89 41 92 36 54 22 40 40 28 66 33 13 80
    24 47 32 60 99 03 45 02 44 75 33 53 78 36 84 20 35 17 12 50
    32 98 81 28 64 23 67 10 26 38 40 67 59 54 70 66 18 38 64 70
    67 26 20 68 02 62 12 20 95 63 94 39 63 08 40 91 66 49 94 21
    24 55 58 05 66 73 99 26 97 17 78 78 96 83 14 88 34 89 63 72
    21 36 23 09 75 00 76 44 20 45 35 14 00 61 33 97 34 31 33 95
    78 17 53 28 22 75 31 67 15 94 03 80 04 62 16 14 09 53 56 92
    16 39 05 42 96 35 31 47 55 58 88 24 00 17 54 24 36 29 85 57
    86 56 00 48 35 71 89 07 05 44 44 37 44 60 21 58 51 54 17 58
    19 80 81 68 05 94 47 69 28 73 92 13 86 52 17 77 04 89 55 40
    04 52 08 83 97 35 99 16 07 97 57 32 16 26 26 79 33 27 98 66
    88 36 68 87 57 62 20 72 03 46 33 67 46 55 12 32 63 93 53 69
    04 42 16 73 38 25 39 11 24 94 72 18 08 46 29 32 40 62 76 36
    20 69 36 41 72 30 23 88 34 62 99 69 82 67 59 85 74 04 36 16
    20 73 35 29 78 31 90 01 74 31 49 71 48 86 81 16 23 57 05 54
    01 70 54 71 83 51 54 69 16 92 33 48 61 43 52 01 89 19 67 48}.map(&:to_i)
    # Patterns of [x,y] increments

  [[1,0],[0,1],[1,1],[-1,1]].map do |dx,dy|
    sx = (dx == -1) ?  3 : 0
    ex = (dx ==  1) ? 16 : 19
    ey = (dy ==  1) ? 16 : 19
    (sx..ex).map do |xv|
      (0..ey).map do |yv|
        grid[(yv       )*20 + xv       ] *
        grid[(yv + dy*1)*20 + xv + dx  ] *
        grid[(yv + dy*2)*20 + xv + dx*2] *
        grid[(yv + dy*3)*20 + xv + dx*3]
      end.max
    end.max
  end.max
end

# What is the value of the first triangle number to have over
# five hundred divisors?
def problem_12(num = 500)
  # I have two versions, the top yields each prime and then does
  # the maths directly for the number of times each prime goes into
  # the number.  The second uses Primes.factors to return the array
  # of prime factors and the big magic line does the maths
  n = 1
  sum = 0
  loop do
    sum += n
    n += 1
    print "Sum = #{sum} => "

    if true
      divisors = 1
      s = sum
      Primes.each do |p|
        break if p > s
        d_count = 1
        while (s % p).zero? && s != 1
          d_count += 1
          s /= p
        end
        divisors *= d_count
      end
    else
      fac = Primes.factors(sum)
      print "#{fac.join(' ')} => "
      # Map to an array of [num,times] values
      # Give the factors, the number of divisors multiplication of the
      # number each of times each prime goes into the number + 1
      divisors = fac.group_by(&:to_i).map {|v,a|
        [v,a.length]}.reduce(1) {|a1,v1| a1 * (v1[1]+1)}
    end
    puts divisors
    return sum if divisors >= num
  end
end

# Find the first ten digits of the sum of one-hundred 50-digit numbers.
def problem_13
  n = %w{
    37107287533902102798797998220837590246510135740250
    46376937677490009712648124896970078050417018260538
    74324986199524741059474233309513058123726617309629
    91942213363574161572522430563301811072406154908250
    23067588207539346171171980310421047513778063246676
    89261670696623633820136378418383684178734361726757
    28112879812849979408065481931592621691275889832738
    44274228917432520321923589422876796487670272189318
    47451445736001306439091167216856844588711603153276
    70386486105843025439939619828917593665686757934951
    62176457141856560629502157223196586755079324193331
    64906352462741904929101432445813822663347944758178
    92575867718337217661963751590579239728245598838407
    58203565325359399008402633568948830189458628227828
    80181199384826282014278194139940567587151170094390
    35398664372827112653829987240784473053190104293586
    86515506006295864861532075273371959191420517255829
    71693888707715466499115593487603532921714970056938
    54370070576826684624621495650076471787294438377604
    53282654108756828443191190634694037855217779295145
    36123272525000296071075082563815656710885258350721
    45876576172410976447339110607218265236877223636045
    17423706905851860660448207621209813287860733969412
    81142660418086830619328460811191061556940512689692
    51934325451728388641918047049293215058642563049483
    62467221648435076201727918039944693004732956340691
    15732444386908125794514089057706229429197107928209
    55037687525678773091862540744969844508330393682126
    18336384825330154686196124348767681297534375946515
    80386287592878490201521685554828717201219257766954
    78182833757993103614740356856449095527097864797581
    16726320100436897842553539920931837441497806860984
    48403098129077791799088218795327364475675590848030
    87086987551392711854517078544161852424320693150332
    59959406895756536782107074926966537676326235447210
    69793950679652694742597709739166693763042633987085
    41052684708299085211399427365734116182760315001271
    65378607361501080857009149939512557028198746004375
    35829035317434717326932123578154982629742552737307
    94953759765105305946966067683156574377167401875275
    88902802571733229619176668713819931811048770190271
    25267680276078003013678680992525463401061632866526
    36270218540497705585629946580636237993140746255962
    24074486908231174977792365466257246923322810917141
    91430288197103288597806669760892938638285025333403
    34413065578016127815921815005561868836468420090470
    23053081172816430487623791969842487255036638784583
    11487696932154902810424020138335124462181441773470
    63783299490636259666498587618221225225512486764533
    67720186971698544312419572409913959008952310058822
    95548255300263520781532296796249481641953868218774
    76085327132285723110424803456124867697064507995236
    37774242535411291684276865538926205024910326572967
    23701913275725675285653248258265463092207058596522
    29798860272258331913126375147341994889534765745501
    18495701454879288984856827726077713721403798879715
    38298203783031473527721580348144513491373226651381
    34829543829199918180278916522431027392251122869539
    40957953066405232632538044100059654939159879593635
    29746152185502371307642255121183693803580388584903
    41698116222072977186158236678424689157993532961922
    62467957194401269043877107275048102390895523597457
    23189706772547915061505504953922979530901129967519
    86188088225875314529584099251203829009407770775672
    11306739708304724483816533873502340845647058077308
    82959174767140363198008187129011875491310547126581
    97623331044818386269515456334926366572897563400500
    42846280183517070527831839425882145521227251250327
    55121603546981200581762165212827652751691296897789
    32238195734329339946437501907836945765883352399886
    75506164965184775180738168837861091527357929701337
    62177842752192623401942399639168044983993173312731
    32924185707147349566916674687634660915035914677504
    99518671430235219628894890102423325116913619626622
    73267460800591547471830798392868535206946944540724
    76841822524674417161514036427982273348055556214818
    97142617910342598647204516893989422179826088076852
    87783646182799346313767754307809363333018982642090
    10848802521674670883215120185883543223812876952786
    71329612474782464538636993009049310363619763878039
    62184073572399794223406235393808339651327408011116
    66627891981488087797941876876144230030984490851411
    60661826293682836764744779239180335110989069790714
    85786944089552990653640447425576083659976645795096
    66024396409905389607120198219976047599490197230297
    64913982680032973156037120041377903785566085089252
    16730939319872750275468906903707539413042652315011
    94809377245048795150954100921645863754710598436791
    78639167021187492431995700641917969777599028300699
    15368713711936614952811305876380278410754449733078
    40789923115535562561142322423255033685442488917353
    44889911501440648020369068063960672322193204149535
    41503128880339536053299340368006977710650566631954
    81234880673210146739058568557934581403627822703280
    82616570773948327592232845941706525094512325230608
    22918802058777319719839450180888072429661980811197
    77158542502016545090413245809786882778948721859617
    72107838435069186155435662884062257473692284509516
    20849603980134001723930671666823555245252804609722
    53503534226472524250874054075591789781264330331690}.reduce(0) do |a,v|
      a + v.to_i
    end.to_s[0,10]
end

# Find the longest sequence using a starting number under one million.
# I hash the sequence of chained values to stop recalculating them.
# I look to see if we have hit the number and then pickup from there.
def problem_14
  chains = {1 => 1}
  max_n,max_v = 1,1
  2.upto(1_000_000).map do |num|
    n = num
    count = 0
    until chains[n]
      n = (n.even? ? (n/2) : (n * 3 +1))
      count += 1
    end
    chains[num] = count += chains[n]
    max_n,max_v = num,count if count > max_v
  end
  max_n
end

# Starting in the top left corner in a 20 by 20 grid, how many routes
# are there to the bottom right corner?
# 2*2 has 6 solutions
def problem_15(width = 20)
  # Each node can be reached via a particular number of paths.  To get
  # to each node, just add the paths to the two preceeding nodes
  a = [1,1]
  (width*2-1).times do
    r = []
    a.each_cons(2) {|a| r << a[0] + a[1] }
    a = [1] + r + [1]
    p a
  end
  a[a.length/2]
end

# What is the sum of the digits of the number 2 ** 1000?
def problem_16(power = 1000)
  (2 ** power).to_s.each_char.map(&:to_i).reduce(&:+)
end

# How many letters would be needed to write all the numbers in
# words from 1 to 1000?
def problem_17(max = 1000)
  words = {
    0 => "",
    1 => "one ", 2 => "two ", 3 => "three ", 4 => "four ", 5 => "five ",
    6 => "six ", 7 => "seven ", 8 => "eight ", 9 => "nine ", 10 => "ten ",
    11 => "eleven ", 12 => "twelve ", 13 => "thirteen ",
    14 => "fourteen", 15 => "fifteen ", 16 => "sixteen ",
    17 => "seventeen ", 18 => "eighteen ", 19 => "nineteen",
    20 => "twenty ", 30 => "thirty ", 40 => "forty", 50 => "fifty ",
    60 => "sixty ", 70 => "seventy ", 80 => "eighty ", 90 => "ninety ",
  }

  to_words = lambda do |num|
    str = ""
    while num > 0
      if num >= 1000    # Thousands
        str = to_words.call(num / 1000) + "thousand"
        num = 0
      elsif num >= 100      # Hundreds
        n = num / 100
        str += to_words.call(n) + "hundred " 
        num -= n * 100
      else # < 100        # Less than 100
        str += "and " if num > 0 and str.length > 0
        if words[num]     # Get pre-known words
          str += words[num]
          num = 0
        else
          n = num / 10 * 10
          if words[n]   # else see if we have a special name
            str += words[n]
            num -= n
          end
          str += words[num]
          num = 0
        end
      end
    end
    str
  end

  (1..max).reduce(0) do |total,num|
    total += (str = to_words.call(num)).tr(" ","").length
    puts "#{num} => #{str} #{total}"
    total
  end
end

# Find the maximum sum travelling from the top of the triangle to the base.
def problem_18(pyramid = %w{
    75
    95 64
    17 47 82
    18 35 87 10
    20 04 82 47 65
    19 01 23 75 03 34
    88 02 77 73 07 63 67
    99 65 04 28 06 16 70 92
    41 41 26 56 83 40 80 70 33
    41 48 72 33 47 32 37 16 94 29
    53 71 44 65 25 43 91 52 97 51 14
    70 11 33 28 77 73 17 78 39 68 17 57
    91 71 52 38 17 14 91 43 58 50 27 29 48
    63 66 04 68 89 53 67 30 73 16 69 87 40 31
    04 62 98 27 23 09 70 98 73 93 38 53 60 04 23}.map(&:to_i))
  py = []
  i = 1
  while pyramid.length > 0
    py << pyramid.shift(i)
    i += 1
  end

  py.reverse.reduce do |a,v|
    v.each_index do |i|
      a[i] = v[i] + [a[i],a[i+1]].max
    end
    a
  end.first
end

# How many Sundays fell on the first of the month during the twentieth century?
def problem_19
  mdays = lambda do |y,m|
    d = [31,28,31, 30,31,30, 31,31,30, 31,30,31][m-1]
    d += 1 if (m == 2) && (y % 4).zero? && (!(y % 100).zero? || (y % 400).zero?)
    d
  end

  num = 0
  total = 1
  (1900..2000).each do |year|
    (1..12).each do |month|
      total += mdays.call(year,month)
      num += 1 if (total % 7).zero? && year >= 1901
    end
  end
  num
end
  
# Find the sum of digits in 100! 26915    
def problem_20(fac = 100)
  1.upto(fac).reduce {|a,v| a * v }.to_s.each_char.map(&:to_i).reduce(&:+)
end

# Evaluate the sum of all amicable pairs under 10000.
def problem_21(num = 9_999)
  sum = 0
  (2..num).each do |n|
    # Generate the sum of the proper divisors of n
    sod = n.sum_of_divisors
    next if n >= sod
    if n == sod.sum_of_divisors
      puts "#{n} #{sod}"
      sum += n + sod # The other will be picked up later
    end
  end
  sum
end

# What is the total of all the name scores in the file of first names?
def problem_22
  names = open("names.txt").read.gsub('"','').split(/,/).sort
  numbers = names.map {|v| v.each_byte.reduce(&:+) - v.length * ?@.ord}
  total = 0
  numbers.each_index {|i| total += numbers[i] * (i+1)}
  total
end

def problem_23
  # First generate the abundant numbers
  max = 28123
  abundant = {}
  (1..max).each do |n|
    abundant[n] = true if n.sum_of_divisors > n
  end

  abundant = abundant.keys.sort
  bad = {}
  abundant.each_with_index do |a,i|
    (i...abundant.size).each do |bi|
      i = a + abundant[bi]
      next if i > max
      bad[i] = true
    end
  end

  sum = 0
  (1..max).each do |n|
    unless bad[n]
      sum += n
    end
  end
  sum
end

if __FILE__ == $0
  p problem_1
  p problem_2
  p problem_3
  p problem_4
  p problem_5
  p problem_6
  p problem_7
  p problem_8
  p problem_9
  p problem_10
  p problem_11
  p problem_12
  p problem_13
  p problem_14
  p problem_15
  p problem_16
  p problem_17
  p problem_18
  p problem_19
  p problem_20
  p problem_21
  p problem_22
  p problem_23
end

