
# Installation

## Development:

0. copy `config/database.yml.example to config/database.yml`

1. edit `/etc/hosts` file and add the following line to it:
```
127.0.0.1  local.spottr.com
```

2. copy `config/application.example.yml` to `config/application.yml`

3. `rails s`

4. go to `http://local.spottr.com:3000`

## Production
1. Create new web app on http://developers.facebook.com (website url is
   http://spottr.com)
2. Go to Settings > Advanced, find "Valid OAuth redirect URIs" and add `http://spottr.com/users/auth/facebook/callback` to it
3. Grab `your_app_id` and `your_app_secret` and set up heroku config variables:

`heroku config:set FACEBOOK_APP_ID=your_app_id`

`heroku config:set FACEBOOK_APP_SECRET=your_app_secret`
