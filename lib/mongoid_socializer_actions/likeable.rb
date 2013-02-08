module Mongoid
  module Likeable
    extend ActiveSupport::Concern

    included do |base|
      base.field    :likers_count, :type => Integer, :default => 0
      base.has_many :likes, :class_name => 'Mongoid::Like', :as => :likable, :dependent => :destroy do
        def liked_by?(model_id)
          where(liker_id: model_id).exists?
        end
      end
    end

    # know if self is liked by model
    #
    # Example:
    # => @photo.liker?(@john)
    # => true
    def liker?(model)
      self.likers_assoc.liked_by?(model.id)
    end

    def liked_by?(model)
      self.likes.liked_by?(model.id)
    end

    # get likers count
    # Note: this is a cache counter
    #
    # Example:
    # => @photo.likers_count
    # => 1
    # def likers_count
    #   self.liked_count_field
    # end

    # get likers count by model
    #
    # Example:
    # => @photo.likers_count_by_model(User)
    # => 1
    def likers_count_by_model(model)
      self.likers_assoc.where(:like_type => model.to_s).count
    end

    # view all selfs likers
    #
    # Example:
    # => @photo.all_likers
    # => [@john, @jashua]
    def likers
      ids = likes.collect{ |like| like.liker_id }
      ids.present? ? User.find(ids) : []
    end

    # view all selfs likers by model
    #
    # Example:
    # => @photo.all_likers_by_model
    # => [@john]
    def all_likers_by_model(model)
      get_likers_of(self, model)
    end

    # view all common likers of self against model
    #
    # Example:
    # => @photo.common_likers_with(@gang)
    # => [@john, @jashua]
    def common_likers_with(model)
      model_likers = get_likers_of(model)
      self_likers = get_likers_of(self)

      self_likers & model_likers
    end

    private
    def get_likers_of(me, model = nil)
      likers = !model ? me.likers_assoc : me.likers_assoc.where(:like_type => model.to_s)

      likers.collect do |like|
        like.like_type.constantize.where(_id: like.like_id).first
      end
    end

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^(.+)_likers_count$/
        likers_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^all_(.+)_likers$/
        all_likers_by_model($1.camelize)
      else
        super
      end
    end
  end
end
