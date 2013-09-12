module Mongoid
  module Followable
    extend ActiveSupport::Concern

    included do |base|
      base.field    :followers_count, :type => Integer, :default => 0
      base.has_many :follows, :class_name => 'Mongoid::Follow', :as => :followable, :dependent => :destroy
      base.has_and_belongs_to_many :followers, :class_name => Socializer.user_class_name, :inverse_of => nil
    end

    # know if self is liked by model
    #
    # Example:
    # => @photo.liked_by?(@john)
    # => true

    def followed_by?(follower)
      follower_ids.include?(follower.id)
    end

    def followers_with_followers_eager_loaded
      follows.includes(:follower)
    end
  end
end
