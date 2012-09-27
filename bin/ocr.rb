#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

require 'sinatra'
require 'sinatra/contrib'
require 'erb'
require 'RMagick'
require 'tesseract'
require "sinatra/reloader" if development?

set :public_folder, File.dirname(__FILE__) + '/../public'

get '/' do
  erb :index
end

post '/ocr' do
  @filepath = Time.now.to_i.to_s + ".jpg"
  Magick::ImageList.new(params[:file][:tempfile].path).threshold(28000).auto_orient.write("./public/#{@filepath}")
  e = Tesseract::Engine.new { |x|
    x.language = :eng
    x.blacklist = '|'
    x.whitelist = '1234567890'
  }
  @ocr = "false"
  
  number = e.text_for("public/#{@filepath}").strip.gsub(/\s/,'')

  @ocr = number #$1 if /(\d{16})/ =~ number
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
