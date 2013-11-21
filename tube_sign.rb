require 'sinatra'
require 'RMagick'
include Magick

get '/' do
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

  text = ['Thom','is blamed'] + params[:text].values.delete_if {|a|a.empty?}

  filename = File.join("public/cache", Digest::MD5.hexdigest(params.to_s)+".png")

  reenie_beanie ='fonts/Reenie_Beanie/ReenieBeanie.ttf'
  gloria = 'fonts/Gloria_Hallelujah/GloriaHallelujah.ttf'
  pointsize_base = 50

  unless File.exists? filename
    # create image
    img = ImageList.new("thom_is_blamed.png") 
    draw = Draw.new
  
    y = 250

    text.each_with_index do | t, i |
      pointsize = if i == 0 
        pointsize_base + 15
      else
        pointsize_base + [*-2..8].sample
      end

      y = y+60
      if i == 0
        draw.annotate(img,0,0,100 -4, y-4, t) {
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
