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