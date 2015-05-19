rm source/version.html
git checkout .
git pull origin master
./deploy.sh
curl -X POST \
      -H "x-instapush-appid: $INSTAPUSH_APPID" \
      -H "x-instapush-appsecret: $INSTAPUSH_APPSECRET" \
      -H "Content-Type: application/json" \
      -d '{"event":"deploy","trackers":{"product":"Notes From Other Places"}}' \
      https://api.instapush.im/post