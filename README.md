Trello 3-Legged OAuth Sinatra Example
=====================================
I created this because it took me far too long to get working and there were
exactly 0 other examples of how to get 3-Legged OAuth working with the
[ruby-trello](https://rubygems.org/gems/ruby-trello) from Sinatra.

You'll need to create a [Trello API key](https://trello.com/c/jObnWvl1/25-generating-your-developer-key).

I assuming a deployment to Heroku, thus the Procfile. You can run them too if
you have the [Heroku Toolbelt](https://toolbelt.heroku.com/).

Running Locally
---------------

```
$ CONSUMER_KEY=1234567890abcdef CONSUMER_SECRET=abcdef1234567890 APP_NAME="3-Legged Cmdline Args" foreman start
```

Deploying to Heroku
-------------------

```
$ heroku create
$ git push heroku master
$ heroku config:set CONSUMER_KEY=1234567890abcdef CONSUMER_SECRET=abcdef123456789 APP_NAME="3-Legged OAuth Example"
```

Running Example
---------------
<http://trello-oauth-sinatra-example.herokuapp.com>
