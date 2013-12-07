def get_content_for file
  File.open("data/articles/#{file}").read 
end

def markdown_for post
	Tilt['markdown'].new { post.markdown }.render(scope=self) 
end