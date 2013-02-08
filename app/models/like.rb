module Mongoid
  class Like
    include Mongoid::Document

    belongs_to :liker, :class_name => 'User', :inverse_of => :likes
    belongs_to :likable, :polymorphic => true
  end
end