echo `git rev-parse HEAD` > source/version.html
middleman build
cd build
s3cmd sync --acl-public --guess-mime-type --recursive . s3://notes-from-other-places.com/
cd ..
rm -rf build