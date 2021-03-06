module Mongoid
  module Likeable
    extend ActiveSupport::Concern

    included do |base|
      base.field    :likers_count, :type => Integer, :default => 0
      base.has_many :likes, :class_name => 'Mongoid::Like', :as => :likable, :dependent => :destroy
      base.has_and_belongs_to_many :likers, :class_name => Socializer.user_class_name, :inverse_of => nil
    end

    # know if self is liked by model
    #
    # Example:
    # => @photo.liked_by?(@john)
    # => true

    def liked_by?(liker)
      liker_ids.include?(liker.id)
    end

    def likes_with_likers_eager_loaded
      likes.includes(:liker)
    end
  end
end
