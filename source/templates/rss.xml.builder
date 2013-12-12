---
layout: false
---
xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.id "#{URI.join(site_url, '/travel')}"
  xml.title "notes from other places"
  xml.subtitle "Blog subtitle"
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated(posts.first.date.to_time.iso8601) unless posts.empty?
  xml.author { xml.name "Ryan Boucher" }

  posts.each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.id URI.join(site_url, article.url)
      xml.published article.published.to_time.iso8601
      xml.updated article.published.to_time.iso8601
      xml.author { xml.name "Ryan Boucher" }

      content = "<h1>#{article.title}</h1><p><a href='#{URI.join(site_url, article.url)}'>Click here or on any photo to view this article in your browser and at their best. If you don't then you'll get tiny images and, probably, lots of words on one line.</a></p>"
      if article.type == 'photo'
        content += "<a href='#{URI.join(site_url, article.url)}'><img src='#{article.thumb}' alt='#{article.title}'/></a>"
      end
      if article.type == 'photos'
        content += "<a href='#{URI.join(site_url, article.url)}'>"
        article.thumbs.each do |thumb|
          content += "<img src='#{thumb}'/>"
        end
        content += "</a>"
      end
      if article.type == 'article'
        content += article.words
      end

      xml.content content, "type" => "html"
    end
  end
end