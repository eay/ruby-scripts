#!/usr/bin/env ruby1.9
#

Dir["euler*.rb"].each do |file|
  unless file == __FILE__[/#{file}$/]
    puts "loading #{file}"
    require file 
  end
end

if __FILE__ == $0
  private_methods.select {|p| /^problem_\d+$/.match p}.map(&:to_s)
    .sort_by {|p| a= p.match(/\d+$/)[0].to_i; puts a; a}.each do |prob|
    puts "#{prob} => #{self.send(prob)}"
  end
end
