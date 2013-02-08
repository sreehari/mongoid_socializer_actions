# -*- encoding: utf-8 -*-

# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mongoid_socializer_actions/version'

Gem::Specification.new do |s|
  s.name        = 'mongoid_socializer_actions'
  s.version     = Mongoid::MongoidSocializerActions::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Sreehari B']
  s.email       = ['sreehari@activesphere.com']
  s.homepage    = 'https://github.com/stigi/mongoid_likes'
  s.summary     = %q{Ability to comment, like, share, tag mongoid documents}
  s.description = %q{Add liking, commentable, sharabel, tagabel ability to Mongoid documents.}

  s.add_dependency 'mongoid', '~> 3.0'
  s.add_dependency 'activesupport', '~> 3.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib', 'app']
end
