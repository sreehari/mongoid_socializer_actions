module Mongoid
  module Commentable
    extend ActiveSupport::Concern

    included do |base|
      base.field    :comments_count, :type => Integer, :default => 0
      base.has_many :comments, :class_name => 'Mongoid::Comment', :as => :commentable, :dependent => :destroy
    end

    # get commenters
    #
    # Example:
    # => @photo.commenters
    # => [@sree, @hari]
    def commenters
      commenter_ids = comments.distinct('commenter_id')
      User.find(commenter_ids)
    end

    # Load comments with commenter
    #
    # Example:
    # => @photo.comments_with_eager_loaded_commenter
    # => [@sree, @hari]
    def comments_with_eager_loaded_commenter
      comments.includes(:commenter)
    end
  end
end
