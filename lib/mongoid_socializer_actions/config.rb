module Socializer
  # Configuration settings
  module Configuration
    attr_writer :user_class_name

    # Example:
    #
    #   Socializer.configure do |configuration|
    #     configuration.user_class_name = 'User'
    #   end

    def configure
      yield self
    end

    def user_class_name
      @user_class_name ||= 'User'
    end
  end
end
