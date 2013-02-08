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
    # => @photo.liked_by?(@john)
    # => true

    def liked_by?(model)
      self.likes.liked_by?(model.id)
    end

    # view all selfs likers
    #
    # Example:
    # => @photo.likers
    # => [@john, @jashua]
    def likers
      ids = likes.collect{ |like| like.liker_id }
      ids.present? ? User.find(ids) : []
    end
  end
end
