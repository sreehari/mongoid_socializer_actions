# mongoid_socializer_actions

mongoid_socializer_actions gives ability to like, comment  mongoid documents


## Installation

Add this line to your application's Gemfile:

    gem 'mongoid_socializer_actions'

And then execute:

    bundle

Or install it yourself as:

    gem install mongoid_socializer_actions


## Requirements

This gem has been tested with [MongoID](http://mongoid.org/) version 3.0.21


## Usage

Mongoid Likes provides two modules that you can mix in your model objects like that:

    class User
      include Mongoid::Document

      include Mongoid::Liker
    end

    class Photo
      include Mongoid::Document

      include Mongoid::Likeable
    end

You can now like objects like this:

    user = User.create
    photo = Photo.create

    user.like(photo)

You can query for likes like that:

    photo.likers
    # => [user]

    photo.likers_count
    # => 1

    user.liked_objects
    # => [photo]

Also likes are polymorphic, so let's assume you have a second class `Album` that is including `Mongoid::Likeable` you can do something like this:

    album = Album.create
    user.like(album)
    user.liked_objects
    # => [photo, album]

    user.liked_ablums
    # => [album]

    user.album_likes_count
    # => 1

You get the idea. Have a look at the specs to see some more examples.

# TODOs

- Implement commentable
- Implement sharable
- Implement taggable