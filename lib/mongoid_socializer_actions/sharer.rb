module Mongoid
  module Sharer
    extend ActiveSupport::Concern

    included do |base|
      base.has_many :shares, :class_name => 'Mongoid::Share', :inverse_of => :sharer, :dependent => :destroy
    end

    # share a model
    #
    # Example:
    # => @john.share(@photo)
    def share(model)
      model.before_shared_by(self) if model.respond_to?('before_shared_by')
      shares << model.shares.create!
      model.inc(:shares_count, 1)
      model.after_shared_by(self) if model.respond_to?('after_shared_by')
      self.before_share(model) if self.respond_to?('before_share')
      self.after_share(model) if self.respond_to?('after_share')
    end

    # unshare a model
    #
    # Example:
    # => @john.unshare(@photo)
    def unshare(model)
      if shared?(model)
        model.reload
        self.reload

        shares.where(:sharable_type => model.class.name, :sharable_id => model.id).destroy
        model.inc(:shares_count, -1)

        model.before_unshare_by(self) if model.respond_to?('before_unshare_by')
        model.after_unshare_by(self) if model.respond_to?('after_unshare_by')
        self.before_unshare(model) if self.respond_to?('before_unshare')
        self.after_unshare(model) if self.respond_to?('after_unshare')
        return true
      else
        return false
      end
    end

    # know if user is already shared model
    #
    # Example:
    # => @john.shared?(@photo)
    # => true
    def shared?(model)
      shares.where(sharable_type: model.class.name, sharable_id: model.id).exists?
    end

    # get likes count by model
    #
    # Example:
    # => @john.shares_count_by_model("Photo")
    # => 1
    def shares_count_by_model(model)
      self.shares.where(:sharable_type => model).count
    end

    # view all selfs shares
    #
    # Example:
    # => @john.liked_objects
    # => [@photo]
    def shared_objects
      get_shared_objects_of_kind
    end

    # view all selfs likes by model
    #
    # Example:
    # => @john.get_shared_objects_of_kind('Photo')
    # => [@photo]
    def get_shared_objects_of_kind(model = nil)
      if model
        user_shares = shares.where(sharable_type: model)
        extract_shares_from(user_shares, model)
      else
        sharable_types = shares.map(&:sharable_type).uniq
        sharable_types.collect do |sharable_type|
          user_shares = shares.select{ |share| share.sharable_type == sharable_type }
          extract_shares_from(user_likes, likable_type)
        end.flatten
      end
    end

    def extract_shares_from(user_shares, sharable_type)
      return [] unless user_shares.present?
      sharable_ids = user_shares.map(&:sharable_id)
      sharable_type.constantize.find(sharable_ids)
    end

    private

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^(.+)_shares_count$/
        shares_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^shared_(.+)$/
        get_shared_objects_of_kind($1.singularize.camelize)
      else
        super
      end
    end
  end
end
