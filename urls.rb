def make_url title
  title.gsub(" ", "-").gsub("'", "").downcase
end

def post_url album, title
  "/travel/#{make_url(album)}/#{make_url(title)}.html"
end

def album_url title
  "/travel/#{make_url(title)}/index.html"
end