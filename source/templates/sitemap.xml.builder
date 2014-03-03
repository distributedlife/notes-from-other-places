---
layout: false
---
xml.instruct!
xml.urlset 'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc URI.join(site_url, "travel")
    xml.lastmod DateTime.now.in_time_zone("Melbourne").to_date.iso8601
    xml.changefreq "daily"
    xml.priority "0.9"
  end

  xml.url do
    xml.loc URI.join(site_url, "travel/recently.html")
    xml.lastmod DateTime.now.in_time_zone("Melbourne").to_date.iso8601
    xml.changefreq "daily"
    xml.priority "0.5"
  end

  albums.each do |album|
    next if album.posts_in_the_past.empty?

    xml.url do
      xml.loc URI.join(site_url, album.url)
      xml.lastmod album.posts_in_the_past.last.published.to_time.iso8601
      xml.changefreq "weekly"
      xml.priority "0.5"
    end
  end

  posts.each do |article|
    xml.url do
      xml.loc URI.join(site_url, article.url)
      xml.lastmod article.published.to_time.iso8601
      xml.changefreq "monthly"
      xml.priority "0.7"
    end
  end
end