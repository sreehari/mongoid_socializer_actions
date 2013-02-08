class User
  include Mongoid::Document
  include Mongoid::Liker

  field :name, type: String
end
