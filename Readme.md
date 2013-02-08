# mongoid_socializer_actions

mongoid_socializer_actions allows you to easily add liking ability to you Mongoid documents.


## Installation

Add the following to your Gemfile

    gem 'mongoid_socializer_actions'


## Requirements

This gem has been tested with [MongoID](http://mongoid.org/) version 3.0.21


## Usage

Mongoid Likes provides two modules that you can mix in your model objects like that:

    class User
      include Mongoid::Document

      include Mongoid::Liker
    end

    class Track
      include Mongoid::Document

      include Mongoid::Likeable
    end

You can now like objects like this:

    user = User.create
    track = Track.create

    user.like(track)

You can query for likes like that:

    track.all_likers
    # => [user]

    track.likers_count
    # => 1

    user.all_likes
    # => [track]

Also likes are polymorphic, so let's assume you have a second class `Album` that is including `Mongoid::Likeable` you can do something like this:

    album = Album.create
    user.like(album)
    user.all_likes
    # => [track, album]

    user.all_likes_by_model(Album)
    # => [album]

    user.track_likes_count
    # => 1

    user.all_track_likes
    # => [track]

You get the idea. Have a look at the specs to see some more examples.

# TODOs

- Implement commentable
- Implement sharable