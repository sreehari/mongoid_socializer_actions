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

##LIKES
Add the liker module in User model and likable in Photo, Album etc.

    class User
      include Mongoid::Document

      include Mongoid::Liker
    end

    class Photo
      include Mongoid::Document

      include Mongoid::Likeable
    end

You can now like, unlike objects like this:

    user = User.create
    photo = Photo.create

    user.like(photo)

    user.unlike(photo)

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

## COMMENTS
Add the Commenter module in User model and Commentable in Photo, Album etc.

    class User
      include Mongoid::Document

      include Mongoid::Commenter
    end

    class Photo
      include Mongoid::Document

      include Mongoid::Commentable
    end

You can now comment objects like this:

    user = User.create
    photo = Photo.create

    user.comment_on(photo, "Beautiful")

Load the commets with eager loaded user(Enable [Identity map](http://mongoid.org/en/mongoid/docs/identity_map.html))

    photo.comments_with_eager_loaded_commenter

You can query for comments like that:

    photo.comments
    # => [comment]

    photo.commenters
    # => [user]

    user.delete_comment(comment_id)
    # => true

    user.edit_comment(comment_id, "Not Beautiful")
    # => true

    user.comments_of(photo)
    # => [comment]

    user.photo_comments_count
    # => 1

    photo.comments_count
    # => 1

    photo.commenters
    # => [user]


# TODOs

- Implement sharable
- Implement taggable