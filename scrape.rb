require 'rubygems' 
require 'mechanize' 
require 'fileutils' 

agent = WWW::Mechanize.new 
signin_page = agent.get('http://www.kodakgallery.com/Signin.jsp') 
signin_page.forms[0].email = 'yourlogin_at_gmail.com' 
signin_page.forms[0].password = 'your_password_here' 
signin_page.forms[0].submit 
 
album_page = agent.get('http://www.kodakgallery.com/AlbumMenu.jsp?Upost_signin=Welcome.jsp') 
albums = album_page.links.map{|l| (l.href.match(/BrowsePhotos.jsp/) && l.text && l.text.match(/[A-Za-z0-9]/)) ? {:href => l.href, :name => l.text} : nil}.compact 
 
albums.each do |album_hash| 
  puts "\n\n\n" 
  puts "-----------------------------------------" 
  puts "'#{album_hash[:name]}'" 
  puts "#{album_hash[:href]}" 
 
  gallery_page = agent.get("http://www.kodakgallery.com/#{album_hash[:href]}") 
  photos = gallery_page.links.map{|l| (l.href.match(/PhotoView.jsp/) && !l.href.match(/javascript/)) ? l.href : nil}.compact.uniq 
 
  album_dirname = album_hash[:name].gsub(/[\n\t\?\:\>\<\\\/|]/, '_') 
 
  unless File.exists?(album_dirname) 
   puts "creating album #{album_dirname}" 
   FileUtils.mkdir(album_dirname) 
  end 
 
  FileUtils.cd(album_dirname, :verbose => true) do 
 
   photos.each do |p| 
    photo_page = agent.get("http://www.kodakgallery.com/#{p}") 
    fullres = photo_page.links.map{|l| (l.href.match(/FullResDownload/) && !l.href.match(/javascript/)) ? l.href : nil}.compact.uniq.first 
 
    file_to_dl = "http://www.kodakgallery.com#{fullres}" 
    result = agent.get(file_to_dl) 
    if result.class == WWW::Mechanize::File 
     result.save 
     puts "Saved #{file_to_dl}" 
    else 
     puts "FAIL on #{file_to_dl}" 
    end 
 
   end 
 
  end 
 
  puts "-----------------------------------------" 
  puts "-----------------------------------------" 
  puts "-----------------------------------------" 
end 
 
