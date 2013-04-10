module Mongoid
  class Like
    include Mongoid::Document
    include Mongoid::Timestamps::Created

    validates :liker, presence: true
    validates :likable, presence: true

    belongs_to :liker, :class_name => Socializer.user_class_name, :inverse_of => :likes
    belongs_to :likable, :polymorphic => true
  end
end
