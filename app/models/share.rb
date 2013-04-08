module Mongoid
  class Share
    include Mongoid::Document

    belongs_to :sharer, :class_name => Socializer.user_class_name, :inverse_of => :shares
    belongs_to :sharable, :polymorphic => true
  end
end