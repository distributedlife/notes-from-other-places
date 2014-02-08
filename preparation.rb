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
        if post.hover?
          post['hover_thumb'] = get_thumb(post.hover)
          post['hover_large'] = get_large(post.hover)
          post['hover_retina'] = get_retina(post.hover)
        end
        post['template'] = 'photo'
      end

      post['url'] = post_url(album.name, post.title)
    end
  end
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
