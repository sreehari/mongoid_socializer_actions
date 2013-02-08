module Mongoid
  module Liker
    extend ActiveSupport::Concern

    included do |base|
      base.field    :likes_count, :type => Integer, :default => 0
      base.has_many :likes, :class_name => 'Mongoid::Like', :inverse_of => :liker, :dependent => :destroy
    end

    # like a model
    #
    # Example:
    # => @john.like(@photo)
    def like(model)
      unless self.liked?(model)
        model.before_liked_by(self) if model.respond_to?('before_liked_by')
        likes << model.likes.create!
        model.inc(:likers_count, 1)
        model.after_liked_by(self) if model.respond_to?('after_liked_by')

        self.before_like(model) if self.respond_to?('before_like')
        # self.likes_assoc.create!(:like_type => model.class.name, :like_id => model.id)
        self.inc(:likes_count, 1)
        self.after_like(model) if self.respond_to?('after_like')
        return true
      else
        return false
      end
    end

    # unlike a model
    #
    # Example:
    # => @john.unlike(@photo)
    def unlike(model)
      if self.id != model.id && self.liked?(model)

        # this is necessary to handle mongodb caching on collection if unlike is following a like
        model.reload
        self.reload

        model.before_unliked_by(self) if model.respond_to?('before_unliked_by')
        likes.where(:likable_type => model.class.name, :likable_id => model.id).destroy
        model.inc(:likers_count, -1)
        model.after_unliked_by(self) if model.respond_to?('after_unliked_by')

        self.before_unlike(model) if self.respond_to?('before_unlike')
        # self.likes_assoc.where(:like_type => model.class.name, :like_id => model.id).destroy
        self.inc(:likes_count, -1)
        self.after_unlike(model) if self.respond_to?('after_unlike')

        return true
      else
        return false
      end
    end

    # know if self is already liking model
    #
    # Example:
    # => @john.liked?(@photos)
    # => true
    def liked?(model)
      self.likes.where(likable_id: model.id, likable_type: model.class.to_s).exists?
    end

    # get likes count by model
    #
    # Example:
    # => @john.likes_count_by_model("Photo")
    # => 1
    def likes_count_by_model(model)
      self.likes.where(:likable_type => model).count
    end

    # view all selfs likes
    #
    # Example:
    # => @john.liked_objects
    # => [@photo]
    def liked_objects
      get_liked_objects_of_kind
    end

    # view all selfs likes by model
    #
    # Example:
    # => @john.get_liked_objects_of_kind('Photo')
    # => [@photo]
    def get_liked_objects_of_kind(model = nil)
      if model
        user_likes = likes.where(likable_type: model)
        extract_likes_from(user_likes, model)
      else
        likable_types = likes.map(&:likable_type).uniq
        likable_types.collect do |likable_type|
          user_likes = likes.select{ |like| like.likable_type == likable_type }
          extract_likes_from(user_likes, likable_type)
        end.flatten
      end
    end

    def extract_likes_from(user_likes, likable_type)
      return [] unless user_likes.present?
      likable_ids = user_likes.map(&:likable_id)
      likable_type.constantize.find(likable_ids)
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^(.+)_likes_count$/
        likes_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^liked_(.+)$/
        get_liked_objects_of_kind($1.singularize.camelize)
      else
        super
      end
    end
  end
end
