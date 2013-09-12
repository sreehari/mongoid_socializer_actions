module Mongoid
  module Follower
    extend ActiveSupport::Concern

    included do |base|
      base.field    :follows_count, :type => Integer, :default => 0
      base.has_many :follows, :class_name => 'Mongoid::Follow', :inverse_of => :follower, :dependent => :destroy
    end

    # follow a model
    #
    # Example:
    # => @john.follow(@page)
    def follow(model)
      unless self.followed?(model)
        model.before_followed_by(self) if model.respond_to?('before_followed_by')
        model.follows.create!(follower: self)
        model.followers << self
        model.inc(:followers_count, 1)
        model.after_followed_by(self) if model.respond_to?('after_followed_by')
        self.before_follow(model) if self.respond_to?('before_follow')
        self.inc(:follows_count, 1)
        self.after_follow(model) if self.respond_to?('after_follow')
        return true
      else
        return false
      end
    end

    # unfollow a model
    #
    # Example:
    # => @john.unfollow(@page)
    def unfollow(model)
      if self.id != model.id && self.followed?(model)

        # this is necessary to handle mongodb caching on collection if unlike is following a like
        model.reload
        self.reload

        model.before_unfollowed_by(self) if model.respond_to?('before_unfollowed_by')

        follows.where(:followable_type => model.class.name, :followable_id => model.id).destroy
        model.followers.delete(self)

        model.inc(:followers_count, -1)
        model.after_unfollowed_by(self) if model.respond_to?('after_unfollowed_by')
        self.before_unfollow(model) if self.respond_to?('before_unfollow')

        self.inc(:follows_count, -1)
        self.after_unfollow(model) if self.respond_to?('after_unfollow')

        return true
      else
        return false
      end
    end

    # know if user is already following model
    #
    # Example:
    # => @john.followed?(@page)
    # => true
    def followed?(model)
      model.follower_ids.include?(self.id)
    end

    # get likes count by model
    #
    # Example:
    # => @john.follows_count_by_model("Photo")
    # => 1
    def follows_count_by_model(model)
      self.follows.where(:followable_type => model).count
    end

    # view all selfs likes
    #
    # Example:
    # => @john.liked_objects
    # => [@photo]
    def followed_objects
      get_followed_objects_of_kind
    end

    # view all selfs likes by model
    #
    # Example:
    # => @john.get_liked_objects_of_kind('Photo')
    # => [@photo]
    def get_followed_objects_of_kind(model = nil)
      if model
        user_likes = likes.where(likable_type: model)
        extract_likes_from(user_likes, model)
      else
        followable_types = follows.map(&:followable_type).uniq
        followable_types.collect do |followable_type|
          user_follows = follows.select{ |follow| follow.followable_type == followable_type }
          extract_follows_from(user_follows, followable_type)
        end.flatten
      end
    end

    def extract_follows_from(user_follows, likable_type)
      return [] unless user_follows.present?
      followable_ids = user_follows.map(&:followable_id)
      followable_type.constantize.find(followable_ids)
    end

    private

    def method_missing(missing_method, *args, &block)
      binding.pry
      if missing_method.to_s =~ /^(.+)_follows_count$/
        follows_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^followed_(.+)$/
        get_followed_objects_of_kind($1.singularize.camelize)
      else
        super
      end
    end
  end
end
