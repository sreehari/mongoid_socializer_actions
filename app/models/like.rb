module Mongoid
  class Like
    include Mongoid::Document
    include Mongoid::Timestamps::Created

    belongs_to :liker, :class_name => 'User', :inverse_of => :likes
    belongs_to :likable, :polymorphic => true
  end
end