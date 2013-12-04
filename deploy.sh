date
echo `git rev-parse HEAD` > source/version.html
gem install bundler
bundle install
bundle exec middleman build
cd build
s3cmd sync --acl-public --guess-mime-type --recursive . s3://distributedlife.com/
cd ..
rm -rf build