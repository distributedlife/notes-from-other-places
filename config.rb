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

def make_url title
  title.gsub(" ", "-").gsub("'", "").downcase
end

def post_url album, title
  "/#{make_url(album)}/#{make_url(title)}.html"
end

def album_url title
  "/#{make_url(title)}/index.html"
end

def posts_in_the_past album
  album['posts'].select {|post| post['published'] < Time.now.to_date}
end

data.albums.each do |album|
  next if album['posts'].nil?
  
  name = album['name']
  sorted_posts_in_the_past = posts_in_the_past(album).sort {|a,b| a['published'] <=> b['published']}
  
  proxy album_url(name), "/templates/cover.html", :locals => {:title => album.name, :album => album, :posts => sorted_posts_in_the_past}

  posts_in_the_past(album).each do |post|
    content = File.open("data/articles/#{post.content}").read unless post.content.nil?
    
    proxy post_url(name, post.title), "/templates/#{post.type}.html", :locals => {
      :title => post.title,
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
  def site_url
    "http://notes-from-other-places.com.s3-website-us-east-1.amazonaws.com"
  end

  def make_url title
    title.gsub(" ", "-").gsub("'", "").downcase
  end

  def post_url album, title
    "/#{make_url(album)}/#{make_url(title)}.html"
  end

  def album_url title
    "/#{make_url(title)}/index.html"
  end

  def get_latest_from albums
    latest = nil

    data.albums.each do |album|
      next if album['posts'].nil?

      posts_in_the_past = album['posts'].select {|post| post['published'] < Time.now.to_date}
      sorted_posts_in_the_past = posts_in_the_past.sort {|a,b| a['published'] <=> b['published']}

      candidate = sorted_posts_in_the_past.reverse.first
      latest = candidate if latest.nil?
      latest = candidate if latest['published'] < candidate['published']
      latest['album'] = album.name unless latest.nil?
    end

    latest
  end

  def get_posts_by_publication_date albums
    posts = []

    data.albums.each do |album|
      next if album['posts'].nil?

      album['posts'].each do |post|
        next if post['published'] > Time.now.to_date
        post['album'] = album.name
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

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

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
