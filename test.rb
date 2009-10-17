
data = DATA.read
puts data.class

r = Regexp.new("^(.*?)(\r?\n){2}(.*)",Regexp::MULTILINE)
m = r.match data
headers = m[1]
body = m[3]

puts "<#{header}>"
puts "<#{body}>"

__END__
header: one
headerA: two

body

footer
