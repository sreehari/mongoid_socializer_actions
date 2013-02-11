class User
  include Mongoid::Document
  include Mongoid::Liker
  include Mongoid::Commenter
  include Mongoid::Sharer

  field :name, type: String
end
