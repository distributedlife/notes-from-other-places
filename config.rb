require 'rubygems'
require 'net/http'
require 'uri'
require 'json'

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end
def api_key
  File.open('api_key', 'r') { |f| f.read }
end

def make_actual_request request
  JSON.parse(Net::HTTP.get_response("api.flickr.com", request).body)
end

def flickr request
  @flickr_call ||= {}
  @flickr_call[request] ||= make_actual_request(request)

  @flickr_call[request]    
end

def get_info photo
  json = flickr "/services/rest/?method=flickr.photos.getInfo&api_key=#{api_key}&photo_id=#{photo}&format=json&nojsoncallback=1"
  
  json['photo']
end

def get_title photo
  get_info(photo)['title']['_content']
end

def make_url title
  title.gsub(" ", "-").gsub("'", "").downcase
end

def post_url album, title
  "/travel/#{make_url(album)}/#{make_url(title)}.html"
end

def album_url title
  "/travel/#{make_url(title)}/index.html"
end

def posts_in_the_past album
  album['posts'].select {|post| post['published'] <= Time.now.to_date}
end

def get_type post
  post.image.nil? ? "article" : "photo"
end

data.albums.each do |album|
  next if album['posts'].nil?  
  name = album['name']

  album['posts'].map do |post|
    post['album'] = album.name
    post['title'] ||= get_title(post.image)
  end

  sorted_posts_in_the_past = posts_in_the_past(album).sort {|a,b| a['published'] <=> b['published']}
  
  proxy album_url(name), "/templates/cover.html", :locals => {:title => album.name, :album => album, :posts => sorted_posts_in_the_past}

  posts_in_the_past(album).each do |post|
    content = File.open("data/articles/#{post.content}").read unless post.content.nil?
    
    title = post.title unless post.title.nil?
    title ||= get_title(post.image)

    proxy post_url(name, title), "/templates/#{get_type(post)}.html", :locals => {
      :title => title,
      :post => post,
      :album => name,
      :posts => sorted_posts_in_the_past,
      :content => content
    }
  end
end

ignore "/templates/cover.html"
ignore "/templates/article.html"
ignore "/templates/photo.html"

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###
helpers do
  def posts_in_the_past album
    album['posts'].select {|post| post['published'] <= Time.now.to_date}
  end

  def site_url
    "http://distributedlife.com/"
  end

  def make_url title
    title.gsub(" ", "-").gsub("'", "").downcase
  end

  def post_url album, title
    "/travel/#{make_url(album)}/#{make_url(title)}.html"
  end

  def album_url title
    "/travel/#{make_url(title)}/index.html"
  end

  def api_key
    File.open('api_key', 'r') { |f| f.read }
  end

  def make_actual_request request
    JSON.parse(Net::HTTP.get_response("api.flickr.com", request).body)
  end

  def flickr request
    @flickr_call ||= {}
    @flickr_call[request] ||= make_actual_request(request)

    @flickr_call[request]    
  end

  def get_size_info name, photo
    json = flickr "/services/rest/?method=flickr.photos.getSizes&api_key=#{api_key}&photo_id=#{photo}&format=json&nojsoncallback=1"    
    
    json['sizes']['size'].select {|size| size['label'] == name}
  end

  def get_info photo
    json = flickr "/services/rest/?method=flickr.photos.getInfo&api_key=#{api_key}&photo_id=#{photo}&format=json&nojsoncallback=1"
    
    json['photo']
  end

  def get_title photo
    get_info(photo)['title']['_content']
  end

  def get_date_taken photo
    Date.parse(get_info(photo)['dates']['taken'])
  end

  def get_thumb photo
    return "" if photo.nil?
    get_size_info("Small 320", photo).first['source']
  end

  def get_large photo
    return "" if photo.nil?
    get_size_info("Large", photo).first['source']
  end

  def get_retina photo
    return "" if photo.nil?

    retina = get_size_info("Large 2048", photo)
    if retina.empty?
      return get_large(photo)
    end

    retina.first['source']
  end

  def get_type post
    post.image.nil? ? "article" : "photo"
  end

  def get_content_for file
    File.open("data/articles/#{file}").read 
  end

  def get_latest_from albums
    latest = nil

    data.albums.each do |album|
      next if album['posts'].nil?

      posts_in_the_past = album['posts'].select {|post| post['published'] < Time.now.to_date}
      sorted_posts_in_the_past = posts_in_the_past.sort {|a,b| a['published'] <=> b['published']}

      candidate = sorted_posts_in_the_past.reverse.first
      next if candidate.nil?

      if latest.nil?
        latest = candidate 
        latest['album'] = album.name unless latest.nil?
        latest['markdown'] = get_content_for(latest.content) unless latest.content.nil?
      end
      unless latest.nil?
        if latest['published'] < candidate['published']
          latest = candidate 
          latest['album'] = album.name unless latest.nil?
          latest['markdown'] = get_content_for(latest.content) unless latest.content.nil?
        end
      end
    end

    latest['date'] ||= get_date_taken(latest.image)
    latest['title'] ||= get_title(latest.image)

    latest
  end

  def get_posts_by_publication_date albums
    posts = []

    data.albums.each do |album|
      next if album['posts'].nil?

      album['posts'].each do |post|
        next unless post['published'] <= Time.now.to_date
        post['album'] = album.name

        post['title'] ||= get_title(post.image)
        post['date'] ||= get_date_taken(post.image)

        posts << post
      end
    end

    posts.sort {|a,b| a['published'] <=> b['published']}.reverse
  end
end

# Automatic image dimensions on image_tag helper
activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# activate :livereload

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'travel/stylesheets'

set :js_dir, 'travel/javascripts'

set :images_dir, 'travel/images'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
