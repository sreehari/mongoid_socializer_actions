class Album
  include Mongoid::Document
  include Mongoid::Likeable
  include Mongoid::Commentable
  include Mongoid::Sharable
  include Mongoid::Followable
end
