module Mongoid
  class Follow
    include Mongoid::Document
    include Mongoid::Timestamps::Created

    validates :follower, presence: true
    validates :followable, presence: true

    belongs_to :follower, :class_name => Socializer.user_class_name, :inverse_of => :follows
    belongs_to :followable, :polymorphic => true
  end
end
