date
echo `git rev-parse HEAD` > source/version.html
gem install bundler --no-rdoc --no-ri
bundle install
bundle exec middleman build --verbose
if [ -d "build" ]; then
	cd build
	s3cmd sync --acl-public --guess-mime-type --recursive . s3://distributedlife.com/
	s3cmd put travel/rss.xml s3://distributedlife.com/travel/rss.xml --mime-type "application/xml" --acl-public
	s3cmd sync --acl-public --guess-mime-type ~/cron.log s3://distributedlife.com/
	cd ..
	rm -rf build
fi