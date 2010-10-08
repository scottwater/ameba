# Ameba

Ameba is a very simple and lightweight blogging engine which runs on Sinatra and Heroku. 

## Features 

* Posts with Title and Body
* ?

Well that is about it. You can write posts. There are no comments, trackbacks, tags, file management, user management, or really another type of admin screens. Setting it up (especially on Heroku) is a snap, but does require use of a command line. 

To be clear, I really don't recommend anyone else actually uses this app (Wordpress, Tumblr, and Posterous are all great alternatives). However, if you are tired of endless features and want something simple, you might find it useful. 

## Future Releases 

I really do not plan on taking things much further than they are now, but if you find a bug or have a suggestion, please fork and send a pull request. 


## Installation

As of today, Ameba uses [MongoDB](http://www.mongodb.org/) for storage. Please follow the instructions on their site for installing MongoDB. Once install, start mongod. 

Basic (local) steps after cloning the repository:  

    gem install bundler 
    bundle install

Then you can run shotgun (installed via bundler above) or rackup. 

## Logging In

As mentioned before, Ameba does not have any admin UI accept for writing a post. Unfortunately, this means you will have one extra step in order to login. 

The easiest way to set up a user locally is with racksh (installed via bundler).

    racksh
    User.create!(:name => "Your Name", :email => "you@email.com", :password => "secret")
    
## Deploying

Once you have your site themed/customized to your liking, there are a couple of things of environment variables you will want to set:

* AMEBA\_SECRET\_KEY - Ameba uses Rack::Session::Cookie. For security (and sanity) you must set this value to use in the production environment. 
* AMEBA\_TITLE - Your site's title
* AMEBA\_SUBTITLE - Your site's subtitle
* AMEBA\_FEED - If you use a feed service like Feedburner
* AMEBA\_SITE\_URL - set the url you want to use for your site. All others (such as Heroku's subdomain) will be redirected

For MongoDB, Ameba is setup by default to look for Heroku's MONGOHQ\_URL variable. 

## Radom Stuff

* If you using RVM, all your gems will end up in a gemset called Ameba
* If you import content from another site, set the :slug property. Ameba will honor it instead of generating it's own.
* Run _rake_ locally to ensure everything is properly setup. 
* New Relic is pre-wired up.
* There is no login link. To login, you need to navigate to /login.