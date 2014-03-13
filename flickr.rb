def api_key
  File.open('api_key', 'r') { |f| f.read }.chomp
end

def fake_reponse
  {
    "photo" => {
      "title" => {
        "_content" => "Fake Title"
      },
      "dates" => {
        "taken" => Date.today.to_s
      }
    },
    "sizes" => {
      "size" => [
        {"label" => "Small 320", "source" => "/travel/fake_thumb.jpg"},
        {"label" => "Large", "source" => "/travel/DSCF6856.jpg"},
        {"label" => "Large 2048", "source" => "/travel/DSCF6856.jpg"}
      ]
    },
    "photoset" => {
      "title" => "Fake Set Title",
      "photo" => [{"id" => "1"}, {"id" => "2"}]
    }
  }
end
def make_actual_request request
  JSON.parse(Net::HTTP.get_response("api.flickr.com", request).body)
  # fake_reponse
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

def get_size_info name, photo
  json = flickr "/services/rest/?method=flickr.photos.getSizes&api_key=#{api_key}&photo_id=#{photo}&format=json&nojsoncallback=1"    
  json['sizes']['size'].select {|size| size['label'] == name}
end

def get_set_info set
  json = flickr "/services/rest/?method=flickr.photosets.getPhotos&api_key=#{api_key}&photoset_id=#{set}&format=json&nojsoncallback=1"
  json['photoset']
end

def get_title photo
  get_info(photo)['title']['_content']
end

def get_date_taken photo
  Date.parse(get_info(photo)['dates']['taken'])
end

def get_set_title set
  get_set_info(set)['title']
end

def get_set_images set
  get_set_info(set)['photo'].map {|photo| photo['id']}
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