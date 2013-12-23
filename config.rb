require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'flickr'
require 'article'
require 'preparation'
require 'urls'
require 'post_collections'
require 'active_support/time'
require 'tzinfo'

albums = prepare_albums(data.albums)

albums.each do |album|
  sorted_posts_in_the_past = posts_in_the_past(album).sort {|a,b| a['published'] <=> b['published']}
  
  proxy album_url(album.name), "/templates/cover.html", :locals => {
    :title => album.name,
    :album => album, 
    :posts => sorted_posts_in_the_past
  }

  album.posts.each do |post|
    content = File.open("data/articles/#{post.content}").read unless post.content.nil?
    
    proxy post.url, "/templates/#{post.template}.html", :locals => {
      :title => post.title,
      :post => post,
      :album => album,
      :posts => sorted_posts_in_the_past,
      :content => content
    }
  end
end

ignore "/templates/*"

proxy "/travel/future.html", "/templates/future.html", :locals => {
  :posts => get_future_posts_by_publication_date(albums),
  :title => "future posts",
  :albums => albums
}

proxy "/travel/recent.html", "/templates/recent.html", :locals => {
  :posts => get_posts_by_publication_date(albums),
  :title => "recently",
  :albums => albums
}

proxy "/travel/index.html", "/templates/index.html", :locals => {
  :title => "latest",
  :latest => get_latest_from(albums),
  :recent => get_posts_by_publication_date(albums),
  :albums => albums
}

proxy "/travel/subscribe.html", "/templates/subscribe.html", :locals => {
  :title => "subscribe"
}

proxy "/travel/rss.xml", "/templates/rss.xml", :locals => {
  :posts => get_posts_by_publication_date(albums)
}

helpers do
  def site_url
    "http://distributedlife.com/"
  end
end

activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# activate :livereload

set :css_dir, 'travel/stylesheets'
set :js_dir, 'travel/javascripts'
set :images_dir, 'travel/images'

configure :build do
  activate :minify_css
  activate :minify_javascript
end
