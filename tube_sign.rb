require 'sinatra'
require 'RMagick'
include Magick

valid_names = ['Any one','Everyone','Thom','Gareth','Dave','Dan','Andy','Steve']
get '/' do
  @names = valid_names
  erb :index
end

get '/list' do

  Dir.chdir("public/cache") do
    @signs = Dir.glob('*.png').sort{|a,b| File.mtime(b) <=> File.mtime(a)}
  end
  @count = @signs.size
  @signs = @signs[0..49]

  erb :list
end 

get '/image.png' do

  who = params[:who]
  # default to thom if null or invalid
  who = 'Thom' if who.nil? 
  who = 'Thom' unless valid_names.include? who
  
  
  text = [who,'is blamed for'] + params[:text].values.delete_if {|a|a.empty?}

  filename = File.join("public/cache", Digest::MD5.hexdigest(text.join('').to_s)+".png")

  reenie_beanie ='fonts/Reenie_Beanie/ReenieBeanie.ttf'
  gloria = 'fonts/Gloria_Hallelujah/GloriaHallelujah.ttf'
  pointsize_base = 50

  unless File.exists? filename
    # note the randomisation ia post hashing of file name
    if who == 'Any one'
      text[0] = (valid_names[1..-1] + ['Thom'] * 30).sample # a little skewed maybe
    end
    
    # create image
    img = ImageList.new("thom_is_blamed.png") 
    draw = Draw.new
  
    y = 150

    text.each_with_index do | t, i |
      pointsize = if i == 0 
        pointsize_base + 15
      else
        pointsize_base + [*-2..8].sample
      end

      y = y+60
      if i == 0
        draw.annotate(img,0,0,100 -3, y-3, t) {
          self.font = reenie_beanie
          self.fill = '#F53842AA'
          self.stroke = 'transparent'
          self.pointsize = pointsize
          self.rotation = [*-5..1].sample
        } 
      end
      draw.annotate(img,0,0,100 + [*-4..4].sample, y, t) {
        self.font = reenie_beanie
        self.fill = '#111a'
        self.stroke = 'transparent'
        self.pointsize = pointsize
        self.rotation = [*-5..1].sample
      }
    end
    # save image
    img.write(filename) do
      self.compression = Magick::ZipCompression
    end
  else
    # load image
    img = ImageList.new(filename)
  end

  #serve image
  content_type 'image/png'
  img.format = "png"
  img.to_blob
end
