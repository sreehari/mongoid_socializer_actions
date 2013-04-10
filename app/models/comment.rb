module Mongoid
  class Comment
    include Mongoid::Document
    include Mongoid::Timestamps

    field :body, type: String
    validates :body, presence: true
    validates :commenter, presence: true
    validates :commentable, presence: true

    belongs_to :commenter, :class_name => Socializer.user_class_name, :inverse_of => :comments
    belongs_to :commentable, :polymorphic => true

    def commentabled_obj
      commentable_type.constantize.find(commentable_id)
    end
  end
end
