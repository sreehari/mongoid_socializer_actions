module Mongoid
  module Commentable
    extend ActiveSupport::Concern

    included do |base|
      base.field    :comments_count, :type => Integer, :default => 0
      base.has_many :comments, :class_name => 'Mongoid::Comment', :as => :commentable, :dependent => :destroy
    end

    def commenters
      commenter_ids = comments.distinct('commenter_id')
      User.find(commenter_ids)
    end
  end
end
