class User
  include Mongoid::Document
  include Mongoid::Liker
  include Mongoid::Commenter
  include Mongoid::Sharer
  include Mongoid::Follower

  field :name, type: String
end
