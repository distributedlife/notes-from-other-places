require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'flickr'
require 'article'

def get_future_posts_by_publication_date albums
  posts = []

  data.albums.each do |album|
    next if album['posts'].nil?

    album['posts'].each do |post|
      next unless post['published'] > Time.now.to_date

      posts << post
    end
  end

  posts.sort {|a,b| a['published'] <=> b['published']}.reverse
end

def posts_in_the_past album
  album['posts'].select {|post| post['published'] <= Time.now.to_date}
end

def get_latest_from albums
  latest = nil

  data.albums.each do |album|
    next if album.posts.nil?

    posts_in_the_past = album['posts'].select {|post| post['published'] <= Time.now.to_date}
    sorted_posts_in_the_past = posts_in_the_past.sort {|a,b| a['published'] <=> b['published']}

    candidate = sorted_posts_in_the_past.reverse.first
    next if candidate.nil?

    if latest.nil?
      latest = candidate 
    end
    unless latest.nil?
      if latest['published'] < candidate['published']
        latest = candidate 
      end
    end
  end

  latest
end

def get_posts_by_publication_date albums
  posts = []

  data.albums.each do |album|
    next if album['posts'].nil?

    album['posts'].each do |post|
      next unless post['published'] <= Time.now.to_date

      posts << post
    end
  end

  posts.sort {|a,b| a['published'] <=> b['published']}.reverse
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

def get_type post
  if post.set.nil?
    if post.image.nil?
      "article"
    else
      if post.image.kind_of?(Array)
        "photos"
      else
        "photo"
      end
    end
  else
    "set"
  end
end

def prepare_albums albums
  albums.select {|album| !album.posts.nil?}.each do |album|
    album['url'] = album_url(album.name)
    album['posts_in_the_past'] = posts_in_the_past(album)

    album['posts'].map do |post|
      post['album'] = album
      post['type'] = get_type(post)

      if post['type'] == "article"
        post['markdown'] = get_content_for(post.content)
        post['words'] = markdown_for post
        post['word_count'] = post['markdown'].split(" ").count.round(-2)
        post['template'] = 'article'
      end
      if post['type'] == "set"
        post['title'] ||= get_set_title(post.set)
        post['image'] = get_set_images(post.set)
        post['type'] = "photos"
        post['template'] = 'photo'
      end
      if post['type'] == "photos"
        post['title'] ||= get_title(post.image.first)
        post['date'] ||= get_date_taken(post.image.first)
        post['thumbs'] = post.image.map { |image| get_thumb(image) }
        post['large_images'] = post.image.map { |image| get_large(image) }
        post['retina_images'] = post.image.map { |image| get_retina(image) }
        post['template'] = 'photo'
      end
      if post['type'] == "photo"
        post['title'] ||= get_title(post.image)
        post['date'] ||= get_date_taken(post.image)
        post['thumb'] = get_thumb(post.image)
        post['large'] = get_large(post.image)
        post['retina'] = get_retina(post.image)
        post['template'] = 'photo'
      end

      post['url'] = post_url(album.name, post.title)
    end
  end
end

albums = prepare_albums(data.albums)

data.albums.each do |album|
  next if album['posts'].nil?

  sorted_posts_in_the_past = posts_in_the_past(album).sort {|a,b| a['published'] <=> b['published']}
  
  proxy album_url(album.name), "/templates/cover.html", :locals => {
    :title => album.name,
    :album => album, 
    :posts => sorted_posts_in_the_past
  }

  posts_in_the_past(album).each do |post|
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

ignore "/templates/cover.html"
ignore "/templates/article.html"
ignore "/templates/photo.html"

proxy "/travel/future.html", "/templates/future.html", :locals => {
  :posts => get_future_posts_by_publication_date(data.albums),
  :title => "future posts",
  :albums => data.albums
}

proxy "/travel/recent.html", "/templates/recent.html", :locals => {
  :posts => get_posts_by_publication_date(data.albums),
  :title => "recently",
  :albums => data.albums
}

proxy "/travel/index.html", "/templates/index.html", :locals => {
  :title => "latest",
  :latest => get_latest_from(data.albums),
  :recent => get_posts_by_publication_date(data.albums),
  :albums => data.albums
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
