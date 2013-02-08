module Mongoid
  module Commenter
    extend ActiveSupport::Concern

    included do |base|
      base.field    :comments_count, :type => Integer, :default => 0
      base.has_many :comments, :class_name => 'Mongoid::Comment', :inverse_of => :commenter, :dependent => :destroy
    end

    # Comment on a model
    #
    # Example:
    # => @john.comment_on(@photo, { with: "Beautiful" } )
    def comment_on(model, comment_body)
        model.before_commented_by(self) if model.respond_to?('before_commented_by')
        comment = model.comments.create!(body: comment_body)
        comments << comment
        model.inc(:comments_count, 1)
        self.inc(:comments_count, 1)
        model.after_commented_by(self) if model.respond_to?('after_commented_by')
        self.before_comment(model) if self.respond_to?('before_comment')
        self.after_comment(model) if self.respond_to?('after_comment')
        comment
    end

    # Delete comment a model
    #
    # Example:
    # => @john.delete_comment(comment_id)
    def delete_comment(model_id)
      comment  = Comment.where(id: model_id).first
      if comment.present?
        comment.commentabled_obj.inc(:comments_count, -1)
        comment.destroy
      end
    end

    # Edit comment a model
    #
    # Example:
    # => @john.edit_comment(comment_id, comment_body)
    def edit_comment(comment_id, comment_body)
      comment  = Comment.where(_id: comment_id).first
      comment.update_attributes(body: comment_body) if comment.present?
    end

    def comments_of(model)
      Comment.where(commentable_type: model.class, commentable_id: model.id)
    end

    # get comments count by model
    #
    # Example:
    # => @john.comments_count_by_model("Photo")
    # => 1
    def comments_count_by_model(model)
      self.comments.where(:likable_type => model).count
    end

    def get_comments_of_kind(model = nil)
      model ? comments.where(likable_type: model) : comments
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^(.+)_comments_count$/
        comments_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^(.+)_comments$/
        get_comments_of_kind($1.singularize.camelize)
      else
        super
      end
    end
  end
end
