class User
  include Mongoid::Document
  include Mongoid::Liker
  include Mongoid::Commenter

  field :name, type: String
end
