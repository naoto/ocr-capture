#!/usr/bin/env ruby

$: << './bin/'

require 'sinatra'
require 'sinatra/contrib'
require 'erb'
require 'RMagick'
require 'tesseract'

set :public_folder, File.dirname(__FILE__) + '/../public'

get '/' do
  erb :index
end

post '/ocr' do
  @filepath = Time.now.to_i.to_s + ".jpg"
  Magick::ImageList.new(params[:file][:tempfile].path).resize_to_fit(240,240).threshold(25000).write("./public/#{@filepath}")
  e = Tesseract::Engine.new { |x|
    x.language = :eng
    x.blacklist = '|'
  }

  @ocr = e.text_for("public/#{@filepath}").strip
  erb :index
end

__END__

@@ index
<html>
<head>
  <title>OCR</title>
</head>
<body>
  <form method="post" action="./ocr" enctype="multipart/form-data">
  <input type="file" name="file" />
  <input type="submit" value="submit" />
  </form>
  <% if !@ocr.nil? %>
  <div><%= @ocr %></div>
  <div><img src="<%= @filepath %>" /></div>
  <% end %>
</body>
</html>
