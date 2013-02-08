module Mongoid
  class Like
    include Mongoid::Document

    # field :like_type
    # field :like_id

    belongs_to :liker, :class_name => 'User', :inverse_of => :likes
    belongs_to :likable, :polymorphic => true
  end
end