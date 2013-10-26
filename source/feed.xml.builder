---
layout: false
---
xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "notes from other places"
  xml.subtitle "Blog subtitle"
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated(get_posts_by_publication_date(data.albums).first.date.to_time.iso8601) unless get_posts_by_publication_date(data.albums).empty?
  xml.author { xml.name "Ryan Boucher" }

  get_posts_by_publication_date(data.albums).each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, post_url(article.album, article.title))
      xml.id URI.join(site_url, post_url(article.album, article.title))
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name "Ryan Boucher" }

      if article.type == 'photo'
        xml.summary Tilt['markdown'].new { "![#{article.title}](#{article.large})" }.render(scope=self) , "type" => "html"
      else
        xml.summary Tilt['markdown'].new { File.open("data/articles/#{article.content}").read }.render(scope=self) , "type" => "html"
      end
      # xml.content article.body, "type" => "html"
    end
  end
end