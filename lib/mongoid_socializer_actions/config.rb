module Socializer
  module Configuration
    attr_writer :user_class_name

    def configure
      yield self
    end

    def user_class_name
      @user_class_name ||= 'User'
    end
  end
end
